require 'rails_helper'

RSpec.describe StripeWebhookController, type: :request do

  let(:stripe_helper) { StripeMock.create_test_helper }
  before { StripeMock.start }
  after { StripeMock.stop }

  let(:stub_stripe_webbook_construct_event) {
    # Stub Stripe::Webook.construct_event to allow our secret for test purposes
    # https://github.com/stripe/stripe-ruby/blob/master/lib/stripe/webhook.rb
    allow(Stripe::Webhook).to receive(:construct_event) do |payload, sig_header, secret|
      raise Stripe::SignatureVerificationError if sig_header != "NameOfTheWind"
      data = JSON.parse(payload, symbolize_names: true)
      Stripe::Event.construct_from(data)
    end
  }

  context "POST /webhooks/stripe" do
    it 'invoice.paid' do 
      user = create(:user, email: 'logan@nine-fingers.com', stripe_customer_id: 'cus_xyBloody9')

      expect(StripeWebhooks::InvoicePaidJob).to receive(:set).with(wait: 5.seconds).exactly(1).times.and_call_original

      stub_stripe_webbook_construct_event
      stripe_event = StripeMock.mock_webhook_event('invoice.paid', {
        customer: "cus_xyBloody9"
      })

      expect {
        post '/stripe_webhook', params: stripe_event.to_json, headers: { 'CONTENT_TYPE' => 'application/json', 'HTTP_STRIPE_SIGNATURE' => 'NameOfTheWind' }
        expect(response.status).to eq(200)
      }.to have_enqueued_job(StripeWebhooks::InvoicePaidJob).with("in_1J96DpDWPLY96bTNg8Bjc0j9")
    end

    it 'invoice.payment_failed' do 
      user = create(:user, :with_payment_method, email: 'nicomo-cosca@famed-solider-of-fortune.com', stripe_customer_id: 'cus_xySworbreck')
      subscription = create(:subscription, :with_plan_assistant, :with_status_active, user: user, stripe_subscription_id: 'su_00WhyGodMe')

      expect(SlackNotificationJob).to receive(:perform_later).with("*Failed Subscription Payment:* nicomo-cosca@famed-solider-of-fortune.com failed payment for subscription Assistant. ").exactly(1).times

      stub_stripe_webbook_construct_event
      stripe_event = StripeMock.mock_webhook_event('invoice.payment_failed', {
        id: "in_dammitSworbreck",
        customer: "cus_xySworbreck",
        subscription: "su_00WhyGodMe",
      })

      post '/stripe_webhook', params: stripe_event.to_json, headers: { 'CONTENT_TYPE' => 'application/json', 'HTTP_STRIPE_SIGNATURE' => 'NameOfTheWind' }
      expect(response.status).to eq(200)
    end
  
    context 'customer.subscription.updated' do 
      it 'All subscription updates' do 
        Timecop.freeze(Time.now) do 
          user = create(:user, :with_payment_method, email: 'nicomo-cosca@famed-solider-of-fortune.com', stripe_customer_id: 'cus_xySworbreck5555')
          subscription = create(:subscription, :with_plan_assistant, :with_status_active, user: user, stripe_subscription_id: 'sub_Jmj5KZvSBP05RO')

          # It'll sync the subscription with counterpart on Stripe
          expect_any_instance_of(Subscription).to receive(:update_from_stripe_subscription!) do |instance|
            expect(instance.id).to eq(subscription.id)
          end.exactly(1).times

          stub_stripe_webbook_construct_event
          stripe_event = StripeMock.mock_webhook_event('customer.subscription.update.renewed', {
            customer: 'cus_xySworbreck5555'
          })
          post '/stripe_webhook', params: stripe_event.to_json, headers: { 'CONTENT_TYPE' => 'application/json', 'HTTP_STRIPE_SIGNATURE' => 'NameOfTheWind' }
          expect(response.status).to eq(200)
        end
      end

      it 'Subscription status changes' do 
        Timecop.freeze(Time.now) do 
          user = create(:user, :with_payment_method, email: 'nicomo-cosca@famed-solider-of-fortune.com', stripe_customer_id: 'cus_xySworbreck5555')
          subscription = create(:subscription, :with_plan_assistant, :with_status_active, user: user, stripe_subscription_id: 'sub_Jmj5KZvSBP05RO')

          # It'll notify on Slack, in addition to normal Stripe sync
          expect(SlackNotificationJob).to receive(:perform_later).with("🧐 *Subscription Status Change:* Subscription #{subscription.id} for nicomo-cosca@famed-solider-of-fortune.com changed from active to past_due ").exactly(1).times
          expect_any_instance_of(Subscription).to receive(:update_from_stripe_subscription!) do |instance|
            expect(instance.id).to eq(subscription.id)
          end.exactly(1).times

          stub_stripe_webbook_construct_event
          stripe_event = StripeMock.mock_webhook_event('customer.subscription.update.status-change-active-to-past-due', {
            customer: 'cus_xySworbreck5555'
          })
          post '/stripe_webhook', params: stripe_event.to_json, headers: { 'CONTENT_TYPE' => 'application/json', 'HTTP_STRIPE_SIGNATURE' => 'NameOfTheWind' }
          expect(response.status).to eq(200)
        end
      end
    end

    it 'customer.subscription.deleted' do 
      user = create(:user, :with_payment_method, email: 'nicomo-cosca@famed-solider-of-fortune.com', stripe_customer_id: 'cus_xyFamed')
      subscription = create(:subscription, :with_plan_assistant, :with_status_active, user: user, stripe_subscription_id: 'sub_JlgbFamedf')

      expect(SlackNotificationJob).to receive(:perform_later).with("⚰️ *Plan Canceled:* nicomo-cosca@famed-solider-of-fortune.com for plan assistant_individual_executive for subscription sub_JlgbFamedf ").exactly(1).times
      expect_any_instance_of(Subscription).to receive(:update_from_stripe_subscription!) do |instance|
        expect(instance.id).to eq(subscription.id)
      end.exactly(1).times

      stub_stripe_webbook_construct_event
      stripe_event = StripeMock.mock_webhook_event('customer.subscription.deleted', {
        id: "sub_JlgbFamedf",
        customer: "cus_xyFamed",
      })
      post '/stripe_webhook', params: stripe_event.to_json, headers: { 'CONTENT_TYPE' => 'application/json', 'HTTP_STRIPE_SIGNATURE' => 'NameOfTheWind' }
      expect(response.status).to eq(200)
    end

    it 'handles invalid payload' do 
      stub_stripe_webbook_construct_event
      post '/stripe_webhook', params: "raw", headers: { 'HTTP_STRIPE_SIGNATURE' => 'NameOfTheWind' }
      expect(response.status).to eq(400)
    end

    it 'handles invalid signature' do 
      stripe_event = StripeMock.mock_webhook_event('customer.subscription.deleted')

      # No Signature
      post '/stripe_webhook', params: stripe_event.to_json, headers: { 'CONTENT_TYPE' => 'application/json' }
      expect(response.status).to eq(400)

      # Bad Signature
      post '/stripe_webhook', params: stripe_event.to_json, headers: { 'CONTENT_TYPE' => 'application/json', 'HTTP_STRIPE_SIGNATURE' => 'SomethingInvalidIAssume' }
      expect(response.status).to eq(400)
    end
  end
end