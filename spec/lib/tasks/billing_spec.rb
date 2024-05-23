require 'rails_helper'

describe "rake billing:daily_stripe_sync", type: :task do
  include StripeMockHelper

  let(:stripe_helper) { StripeMock.create_test_helper }
  before { 
    StripeMock.start 

    # Create mock Stripe objects
    stripe_helper.create_plan({
      id: 'assistant_individual_executive', 
      product: stripe_helper.create_product(id: "prod_assistant").id, 
      amount: 20000, 
      currency: 'jpy'
    })
    stripe_helper.create_plan({
      id: 'mail_pro', 
      product: stripe_helper.create_product(id: "prod_mail").id, 
      amount: 88000, 
      currency: 'jpy'
    })

    @stripe_customer = Stripe::Customer.create(source: stripe_mock_generate_card_token, currency: 'jpy')

    @active_to_canceled_stripe = Stripe::Subscription.create({
      customer: @stripe_customer.id,
      items: [{ plan: 'assistant_individual_executive' }]
    })
    @active_to_canceled_stripe.delete

    @past_due_to_active_stripe = Stripe::Subscription.create({
      customer: @stripe_customer.id,
      items: [{ plan: 'mail_pro' }],
    })

    @active_to_past_due_stripe = Stripe::Subscription.create({
      customer: @stripe_customer.id,
      items: [{ plan: 'mail_pro' }],
    })
    StripeMock.mark_subscription_as_past_due(@active_to_past_due_stripe)

    @active_unchanged_stripe = Stripe::Subscription.create({
      customer: @stripe_customer.id,
      items: [{ plan: 'assistant_individual_executive' }]
    })
  }
  after { StripeMock.stop }

  context 'syncs Stripe subscriptions' do 
    it 'ensure right method call' do
      Subscription.destroy_all
      Timecop.freeze(Time.now) do 
        active_to_canceled = create(:subscription, :with_plan_assistant, :with_status_active, stripe_subscription_id: @active_to_canceled_stripe.id)
        past_due_to_active = create(:subscription, :with_plan_mail, :with_status_past_due, stripe_subscription_id: @past_due_to_active_stripe.id)
        active_to_past_due = create(:subscription, :with_plan_mail, :with_status_active, stripe_subscription_id: @active_to_past_due_stripe.id)
        active_unchanged = create(:subscription, :with_plan_assistant, :with_status_active, stripe_subscription_id: @active_unchanged_stripe.id)

        call_count = 0
        allow_any_instance_of(Subscription).to receive(:update_from_stripe_subscription!) do |instance|
          expect(instance.id).to be_in([active_to_canceled.id, past_due_to_active.id, active_to_past_due.id, active_unchanged.id])
          call_count += 1
        end

        Timecop.travel(10.minutes)
        task.execute

        expect(call_count).to eq(4)
      end
    end

    it 'smokescreen for attributes updated' do 
      pending("Stripe-mock not recognizing start_date")
      Subscription.destroy_all
      Timecop.freeze(Time.now) do 
        active_to_canceled = create(:subscription, :with_plan_assistant, :with_status_active, stripe_subscription_id: @active_to_canceled_stripe.id)
        past_due_to_active = create(:subscription, :with_plan_mail, :with_status_past_due, stripe_subscription_id: @past_due_to_active_stripe.id)
        active_to_past_due = create(:subscription, :with_plan_mail, :with_status_active, stripe_subscription_id: @active_to_past_due_stripe.id)
        active_unchanged = create(:subscription, :with_plan_assistant, :with_status_active, stripe_subscription_id: @active_unchanged_stripe.id)

        expect(active_to_canceled.status).to eq('active')
        expect(active_to_canceled.updated_at).to be_within(1.minute).of(Time.now)
        expect(past_due_to_active.status).to eq('past_due')
        expect(past_due_to_active.updated_at).to be_within(1.minute).of(Time.now)
        expect(active_to_past_due.status).to eq('active')
        expect(active_to_past_due.updated_at).to be_within(1.minute).of(Time.now)
        expect(active_unchanged.status).to eq('active')
        expect(active_unchanged.updated_at).to be_within(1.minute).of(Time.now)

        Timecop.travel(10.minutes)
        task.execute

        active_to_canceled.reload
        expect(active_to_canceled.status).to eq('canceled')
        expect(active_to_canceled.updated_at).to be_within(1.minute).of(Time.now)
        past_due_to_active.reload
        expect(past_due_to_active.status).to eq('active')
        expect(past_due_to_active.updated_at).to be_within(1.minute).of(Time.now)
        active_to_past_due.reload
        expect(active_to_past_due.status).to eq('past_due')
        expect(active_to_past_due.updated_at).to be_within(1.minute).of(Time.now)
        active_unchanged.reload
        expect(active_unchanged.status).to eq('active')
        expect(active_unchanged.updated_at).to be_within(1.minute).of(Time.now)
      end
    end
  end
end