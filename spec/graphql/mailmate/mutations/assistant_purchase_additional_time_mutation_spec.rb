require 'rails_helper'

RSpec.describe Mailmate::Mutations::AssistantPurchaseAdditionalTimeMutation, type: :request do
  include MailmateGraphQLHelper

  before do 
    StripeMock.start
  end

  after do
    StripeMock.stop
  end

  it 'authenticates user' do
    ensure_user_authenticated(query(120, 14000)) 
  end

  it 'purchases additional minutes' do 
    user = create(:user, :with_payment_method, email: 'spensa+assistantpurchaseadditionaltimemutation@skyward.io')
    subscription = create(:subscription, :with_plan_assistant, user: user)
    expect(user.payments.count).to eq(0)
    expect(user.time_allocations.count).to eq(0)

    expect(Assistant::Services::PurchaseAdditionalTime).to receive(:purchase_amount).with(minutes: 120).exactly(2).times.and_call_original # called in Assistant::Services::PurchaseAdditionalTime too
    expect(Assistant::Services::PurchaseAdditionalTime).to receive(:call).with(user: user, minutes: 120).exactly(1).times.and_call_original
    expect(SlackNotificationJob).to receive(:perform_later).with("*Extra Time Purchased:* spensa+assistantpurchaseadditionaltimemutation@skyward.io has purchased 2 hours (via dashboard). ")

    authorized_request(user, query(120, 14000)) 
    data = response.parsed_body['data']['assistantPurchaseAdditionalTime']
    expect(data).to eq({
      "success"=>true,
      "errorMessage"=>nil
    })

    user.reload
    expect(user.payments.count).to eq(1)
    expect(user.payments.last.total.cents).to eq(14000)
    expect(user.time_allocations.count).to eq(1)
    expect(user.time_allocations.last.minutes).to eq(120)
  end

  it 'returns error if incorrect purchase amount shown' do 
    user = create(:user, :with_payment_method)
    subscription = create(:subscription, :with_plan_assistant, user: user)
    expect(user.payments.count).to eq(0)
    expect(user.time_allocations.count).to eq(0)

    expect(Assistant::Services::PurchaseAdditionalTime).to_not receive(:call)
    expect(SlackNotificationJob).to receive(:perform_later).with("*🛠 Dev Debug:* AssistantPurchaseAdditionalTimeMutation caught wrong purchase amount shown: 7000 vs 14000, for user #{user.id}")

    # Tries to purchase 2 hours when shown price for 1 hour
    expect(Assistant::Services::PurchaseAdditionalTime.purchase_amount(minutes: 60)).to eq(7000)
    authorized_request(user, query(120, 7000)) 
    data = response.parsed_body['data']['assistantPurchaseAdditionalTime']
    expect(data).to eq({
      "success"=>false,
      "errorMessage"=>"The purchase amount you were shown was incorrect, you have not been charged"
    })

    user.reload
    expect(user.payments.count).to eq(0)
    expect(user.time_allocations.count).to eq(0)
  end

  it 'returns error for known service errors' do 
    user = create(:user, :with_payment_method)

    expect(SlackNotificationJob).to_not receive(:perform_later)

    # No subscription
    expect(user.subscriptions.count).to eq(0)
    authorized_request(user, query(120, 14000)) 
    data = response.parsed_body['data']['assistantPurchaseAdditionalTime']
    expect(data).to eq({
      "success"=>false,
      "errorMessage"=>"No assistant subscription found"
    })
    user.reload
    expect(user.payments.count).to eq(0)
    expect(user.time_allocations.count).to eq(0)

    # Overpurchase (3 hours available but tries for 4)
    subscription = create(:subscription, :with_plan_assistant, user: user)
    authorized_request(user, query(240, 28000)) 
    data = response.parsed_body['data']['assistantPurchaseAdditionalTime']
    expect(data).to eq({
      "success"=>false,
      "errorMessage"=>"Requested time to purchase exceeds current available time to purchase"
    })
    user.reload
    expect(user.payments.count).to eq(0)
    expect(user.time_allocations.count).to eq(0)

    # Stripe card error
    stripe_card_error = Stripe::CardError.new(
      'Card was declined for some reason',
      'param', 
      json_body: {'error' => { 'payment_intent' => { 'id' => 'stub_pi_123' } }}
    )
    expect(Stripe::PaymentIntent).to receive(:create).and_raise(stripe_card_error)
    authorized_request(user, query(120, 14000)) 
    data = response.parsed_body['data']['assistantPurchaseAdditionalTime']
    expect(data).to eq({
      "success"=>false,
      "errorMessage"=>"Card was declined for some reason"
    })
    user.reload
    expect(user.payments.count).to eq(0)
    expect(user.time_allocations.count).to eq(0)
  end
 
  def query(minutes, purchase_amount_shown)
    <<~GQL
      mutation {
        assistantPurchaseAdditionalTime(input: { minutes: #{minutes}, purchaseAmountShown: #{purchase_amount_shown} } ) {
          success
          errorMessage
        }
      }
    GQL
  end
end