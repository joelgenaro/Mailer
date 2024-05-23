require 'rails_helper'

RSpec.describe StripeWebhooks::InvoicePaidJob, type: :job do
  include ActiveJob::TestHelper
  include StripeMockHelper

  let(:stripe_helper) { StripeMock.create_test_helper }
  before { 
    StripeMock.start 

    # Mock Stripe plan & customer
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
  }
  after { StripeMock.stop }

  it 'common' do 
    pending("Stripe-mock not recognizing start_date")
    # Mock Stripe subscription & invoice
    stripe_subscription = Stripe::Subscription.create({
      customer: @stripe_customer.id,
      items: [{ plan: 'mail_pro' }]
    })
    stripe_invoice = Stripe::Invoice.create(customer: @stripe_customer.id, subscription: stripe_subscription.id)

    # Create user and mail subscription
    user = create(:user, :with_payment_method)
    subscription = create(:subscription, :with_plan_mail, :with_status_active, user: user, stripe_subscription_id: stripe_subscription.id)

    # Updates the subscription, based on the Stripe Subscription
    expect_any_instance_of(Subscription).to receive(:update_from_stripe_subscription!).exactly(1).times.and_call_original

    # Perform the job
    perform_enqueued_jobs { StripeWebhooks::InvoicePaidJob.perform_later(stripe_invoice.id) }
  end

  context 'handles assistant subscription renewal' do 
    it 'allocates time' do 
      pending("Stripe-mock not recognizing start_date")
      Timecop.freeze(Time.parse("2021-10-03T11:11:57Z")) do 
        # Mock Stripe subscription & invoice
        stripe_subscription = Stripe::Subscription.create({
          customer: @stripe_customer.id,
          items: [{ plan: 'assistant_individual_executive' }]
        })
        stripe_invoice = Stripe::Invoice.create(customer: @stripe_customer.id, subscription: stripe_subscription.id)

        # Create user, assistant subscription & preflight check
        user = create(:user, :with_payment_method, email: 'orso@stripe-webhooks-invoice-paid-job.jp')
        subscription = create(:subscription, :with_plan_assistant, :with_status_active, user: user, stripe_subscription_id: stripe_subscription.id)
        expect(subscription.billing_started_at.iso8601).to eq("2021-05-02T11:11:15Z")
        expect(subscription.billing_period_started_at.iso8601).to eq("2021-09-02T11:11:15Z")
        expect(subscription.billing_period_ends_at.iso8601).to eq("2021-10-02T11:11:15Z")
        expect(user.time_allocations.count).to eq(0)

        # Will notify on Slack
        expect(SlackNotificationJob).to receive(:perform_later).with("*Subscription Renewed:* orso@stripe-webhooks-invoice-paid-job.jp has been billed for their monthly subscription to assistant_individual_executive. ").exactly(1).times

        # Updates the subscription, based on the Stripe Subscription
        expect_any_instance_of(Subscription).to receive(:update_from_stripe_subscription!).exactly(1).times.and_call_original

        # Perform the job
        perform_enqueued_jobs { StripeWebhooks::InvoicePaidJob.perform_later(stripe_invoice.id) }

        # Update subscription dates
        subscription.reload
        expect(subscription.billing_started_at.iso8601).to eq("2011-06-20T18:37:18Z") # This is a result of the StripeMock fixture
        expect(subscription.billing_period_started_at.iso8601).to eq("2021-10-03T11:11:57Z")
        expect(subscription.billing_period_ends_at.iso8601).to eq("2021-11-03T11:11:57Z")

        # Creates time allocation
        user.reload
        expect(user.time_allocations.count).to eq(1)
        expect(user.time_allocations.last.minutes).to eq(300)
        expect(user.time_allocations.last.valid_from.iso8601).to eq("2021-10-03T11:11:57Z")
        expect(user.time_allocations.last.valid_to.iso8601).to eq("2021-11-02T11:11:57Z") # 30 days from today
        expect(user.time_allocations.last.source).to eq('subscription')
      end
    end

    it 'does not allocate time if first invoice for' do 
      pending("Stripe-mock not recognizing start_date")
      Timecop.freeze(Time.parse("2011-06-20T18:37:18Z")) do # Use same date as StripeMock fixture
        # Mock Stripe subscription & invoice
        stripe_subscription = Stripe::Subscription.create({
          customer: @stripe_customer.id,
          items: [{ plan: 'assistant_individual_executive' }]
        })
        stripe_invoice = Stripe::Invoice.create(customer: @stripe_customer.id, subscription: stripe_subscription.id)

        # Create user, assistant subscription & preflight check
        user = create(:user, :with_payment_method, email: 'glokta@stripe-webhooks-invoice-paid-job.jp')
        subscription = create(:subscription, :with_plan_assistant, :with_status_active, user: user, stripe_subscription_id: stripe_subscription.id)
        expect(subscription.billing_started_at.iso8601).to eq("2021-05-02T11:11:15Z") # These dates are from factory
        expect(subscription.billing_period_started_at.iso8601).to eq("2021-09-02T11:11:15Z")
        expect(subscription.billing_period_ends_at.iso8601).to eq("2021-10-02T11:11:15Z")
        expect(user.time_allocations.count).to eq(0)

        # Will not notify on Slack
        expect(SlackNotificationJob).to_not receive(:perform_later)

        # Perform the job
        perform_enqueued_jobs { StripeWebhooks::InvoicePaidJob.perform_later(stripe_invoice.id) }

        # Still updates subscription in any case
        subscription.reload
        expect(subscription.billing_started_at.iso8601).to eq("2011-06-20T18:37:18Z")
        expect(subscription.billing_period_started_at.iso8601).to eq("2011-06-20T18:37:18Z")
        expect(subscription.billing_period_ends_at.iso8601).to eq("2011-07-20T18:37:18Z")

        # Desn't allocate time, as subscription start and it's current period start are same
        user.reload
        expect(user.time_allocations.count).to eq(0)
      end
    end
  end

  context 'handles mail subscription renewal' do 
    it 'allocates credits' do 
      pending("Stripe-mock not recognizing start_date")
      Timecop.freeze(Time.parse("2021-10-03T11:11:57Z")) do 
        # Mock Stripe subscription & invoice
        stripe_subscription = Stripe::Subscription.create({
          customer: @stripe_customer.id,
          items: [{ plan: 'mail_pro' }]
        })
        stripe_invoice = Stripe::Invoice.create(customer: @stripe_customer.id, subscription: stripe_subscription.id)

        # Create user, mail subscription & preflight check
        user = create(:user, :with_payment_method, email: 'orso@stripe-webhooks-invoice-paid-job.jp')
        subscription = create(:subscription, :with_plan_mail, :with_status_active, user: user, stripe_subscription_id: stripe_subscription.id, plan: :mail_pro)
        expect(subscription.billing_started_at.iso8601).to eq("2021-05-02T11:11:15Z")
        expect(subscription.billing_period_started_at.iso8601).to eq("2021-09-02T11:11:15Z")
        expect(subscription.billing_period_ends_at.iso8601).to eq("2021-10-02T11:11:15Z")
        expect(user.inbox.credit_transactions.count).to eq(0)

        # Will notify on Slack
        expect(SlackNotificationJob).to receive(:perform_later).with("*Subscription Renewed:* orso@stripe-webhooks-invoice-paid-job.jp has been billed for their monthly subscription to mail_pro. ").exactly(1).times

        # Updates the subscription, based on the Stripe Subscription
        expect_any_instance_of(Subscription).to receive(:update_from_stripe_subscription!).exactly(1).times.and_call_original

        # Will call credit allocation method
        expect(Mail::CreditTransaction).to receive(:create_monthly_allocations_for_plan!).once.and_call_original

        # Perform the job
        perform_enqueued_jobs { StripeWebhooks::InvoicePaidJob.perform_later(stripe_invoice.id) }

        # Update subscription dates
        subscription.reload
        expect(subscription.billing_started_at.iso8601).to eq("2011-06-20T18:37:18Z") # This is a result of the StripeMock fixture
        expect(subscription.billing_period_started_at.iso8601).to eq("2021-10-03T11:11:57Z")
        expect(subscription.billing_period_ends_at.iso8601).to eq("2021-11-03T11:11:57Z")

        # Creates credit allocations
        user.reload
        expect(user.inbox.credit_transactions.count).to eq(2)
        credit_transaction_mail_content_scan = user.inbox.credit_transactions.with_credit_type(:mail_content_scan).last
        expect(credit_transaction_mail_content_scan.balance).to eq(110)
        expect(credit_transaction_mail_content_scan.expires_at).to be_within(1.second).of(Time.now + 30.days)
        credit_transaction_mail_translation_summary = user.inbox.credit_transactions.with_credit_type(:mail_translation_summary).last
        expect(credit_transaction_mail_translation_summary.balance).to eq(110)
        expect(credit_transaction_mail_translation_summary.expires_at).to be_within(1.second).of(Time.now + 30.days)
      end
    end

    it 'does not allocate credits if first invoice for' do 
      pending("Stripe-mock not recognizing start_date")
      Timecop.freeze(Time.parse("2011-06-20T18:37:18Z")) do # Use same date as StripeMock fixture
        # Mock Stripe subscription & invoice
        stripe_subscription = Stripe::Subscription.create({
          customer: @stripe_customer.id,
          items: [{ plan: 'mail_pro' }]
        })
        stripe_invoice = Stripe::Invoice.create(customer: @stripe_customer.id, subscription: stripe_subscription.id)

        # Create user, assistant subscription & preflight check
        user = create(:user, :with_payment_method, email: 'glokta@stripe-webhooks-invoice-paid-job.jp')
        subscription = create(:subscription, :with_plan_mail, :with_status_active, user: user, stripe_subscription_id: stripe_subscription.id, plan: :mail_pro)
        expect(subscription.billing_started_at.iso8601).to eq("2021-05-02T11:11:15Z") # These dates are from factory
        expect(subscription.billing_period_started_at.iso8601).to eq("2021-09-02T11:11:15Z")
        expect(subscription.billing_period_ends_at.iso8601).to eq("2021-10-02T11:11:15Z")
        expect(user.inbox.credit_transactions.count).to eq(0)

        # Will not notify on Slack
        expect(SlackNotificationJob).to_not receive(:perform_later)

        # Will not call credit allocation method 
        expect(Mail::CreditTransaction).to_not receive(:create_monthly_allocations_for_plan!)

        # Perform the job
        perform_enqueued_jobs { StripeWebhooks::InvoicePaidJob.perform_later(stripe_invoice.id) }

        # Still updates subscription in any case
        subscription.reload
        expect(subscription.billing_started_at.iso8601).to eq("2011-06-20T18:37:18Z")
        expect(subscription.billing_period_started_at.iso8601).to eq("2011-06-20T18:37:18Z")
        expect(subscription.billing_period_ends_at.iso8601).to eq("2011-07-20T18:37:18Z")

        # Desn't allocate credits
        user.reload
        expect(user.inbox.credit_transactions.count).to eq(0)
      end
    end
  end

  it 'handles when non-subscription invoice' do 
    stripe_invoice = Stripe::Invoice.create(customer: @stripe_customer.id)
    # Will notify on Slack
    expect(SlackNotificationJob).to receive(:perform_later).with("*🛠 Dev Debug:* StripeWebhooks::InvoicePaidJob received invoice with no subscription id: #{stripe_invoice.id} ").exactly(1).times
    # Perform the job
    perform_enqueued_jobs { StripeWebhooks::InvoicePaidJob.perform_later(stripe_invoice.id) }
  end

  it 'handles Stripe invalid request error' do 
    stripe_invoice = Stripe::Invoice.create(customer: @stripe_customer.id, subscription: 'sub_baaaad')
    subscription = create(:subscription, :with_plan_assistant, :with_status_active, stripe_subscription_id: 'sub_baaaad')

    # Will notify on Slack
    expect(SlackNotificationJob).to receive(:perform_later).with("*🛠 Dev Debug:* StripeWebhooks::InvoicePaidJob encountered Stripe::InvalidRequestError for: #{stripe_invoice.id} ").exactly(1).times
    # Perform the job
    perform_enqueued_jobs { StripeWebhooks::InvoicePaidJob.perform_later(stripe_invoice.id) }
  end
end