require 'rails_helper'

RSpec.describe Assistant::Services::SetupAccount, type: :service do
  include StripeMockHelper

  let(:stripe_helper) { StripeMock.create_test_helper }
  before { 
    StripeMock.start 

    # Create mock Stripe price for Assistant plan
    stripe_helper.create_plan({
      id: 'assistant_individual_executive', 
      product: stripe_helper.create_product.id, 
      amount: 20000, 
      currency: 'jpy'
    })

    # Create mock Stripe subscription
    stripe_customer = Stripe::Customer.create(source: stripe_mock_generate_card_token, currency: 'jpy')
    expect(stripe_customer.subscriptions.count).to eq(0)
    @stripe_subscription = Stripe::Subscription.create({
      customer: stripe_customer.id,
      items: [{ plan: 'assistant_individual_executive' }]
    })
  }
  after { StripeMock.stop }
  
  it 'is sucessful' do 
    pending("Stripe-mock not recognizing start_date")
    Timecop.freeze("2021-09-29T18:19:25Z") do 
      # Create user
      user = create(:user)
      expect(user.task_list).to be_nil
      expect(user.subscriptions.count).to eq(0)
      expect(user.time_allocations.count).to eq(0)

      # Do it!
      Assistant::Services::SetupAccount.call(
        user: user,
        plan: :assistant_individual_executive,
        stripe_subscription: @stripe_subscription
      )

      user.reload

      # Creates assistant task list
      expect(user.task_list).to be_present

      # Creates subscription record
      expect(user.subscriptions.count).to eq(1)
      expect(user.subscriptions.last.plan_type).to eq('assistant')
      expect(user.subscriptions.last.plan).to eq('assistant_individual_executive')
      expect(user.subscriptions.last.stripe_subscription_id).to eq(@stripe_subscription.id)
      expect(user.subscriptions.last.status).to eq('active')
      expect(user.subscriptions.last.billing_started_at.iso8601).to eq('2011-06-20T18:37:18Z')
      expect(user.subscriptions.last.billing_period_started_at).to eq(Time.at(@stripe_subscription.current_period_start))
      expect(user.subscriptions.last.billing_period_ends_at).to eq(Time.at(@stripe_subscription.current_period_end))

      # Creates correct time allocation
      expect(user.time_allocations.count).to eq(1)
      expect(user.time_allocations.last.minutes).to eq(300)
      expect(user.time_allocations.last.minutes).to eq(Assistant::PricingPlansV2.find(:assistant_individual_executive)[:configuration][:minutes])
      expect(user.time_allocations.last.valid_from.iso8601).to eq("2021-09-29T18:19:25Z")
      expect(user.time_allocations.last.valid_to.iso8601).to eq("2021-10-29T18:19:25Z")
      expect(user.time_allocations.last.source).to eq("subscription")
    end
  end

  it 'handles exceptions' do
    pending("Stripe-mock not recognizing start_date")
    # Create user
    user = create(:user)
    expect(user.task_list).to be_nil
    expect(user.subscriptions.count).to eq(0)
    expect(user.time_allocations.count).to eq(0)

    expect(Sentry).to receive(:capture_exception).exactly(2).times

    # Bad Stripe subscription object
    expect { 
      Assistant::Services::SetupAccount.call(
        user: user,
        plan: :assistant_individual_executive,
        stripe_subscription: nil
      )
    }.to raise_error do |error| 
      expect(error.code).to eq('assistant.services.setupAccount')
      expect(error.message).to eq('Encountered error setting up account')
      expect(error.extra[:exception_message]).to include("undefined method `id' for nil:NilClass")
    end

    # Transaction rolls everything back
    expect(user.task_list).to be_nil
    expect(user.subscriptions.count).to eq(0)
    expect(user.time_allocations.count).to eq(0)

    # Invalid plan
    expect { 
      Assistant::Services::SetupAccount.call(
        user: user,
        plan: 'invalid',
        stripe_subscription: @stripe_subscription
      )
    }.to raise_error do |error| 
      expect(error.code).to eq('assistant.services.setupAccount')
      expect(error.message).to eq('Encountered error setting up account')
      expect(error.extra[:exception_message]).to eq("Validation failed: Plan is not valid for plan type")
    end

    # Transaction rolls everything back
    expect(user.task_list).to be_nil
    expect(user.subscriptions.count).to eq(0)
    expect(user.time_allocations.count).to eq(0)
  end
end