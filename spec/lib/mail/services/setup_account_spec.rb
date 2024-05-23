require 'rails_helper'

RSpec.describe Mail::Services::SetupAccount, type: :service do
  include StripeMockHelper

  let(:stripe_helper) { StripeMock.create_test_helper }
  before { 
    StripeMock.start 

    # Create mock Stripe price for Mail plan
    stripe_helper.create_plan({
      id: 'mail_standard', 
      product: stripe_helper.create_product.id, 
      amount: 28000, 
      currency: 'jpy'
    })

    # Create mock Stripe subscription
    stripe_customer = Stripe::Customer.create(source: stripe_mock_generate_card_token, currency: 'jpy')
    expect(stripe_customer.subscriptions.count).to eq(0)
    @stripe_subscription = Stripe::Subscription.create({
      customer: stripe_customer.id,
      items: [{ plan: 'mail_standard' }]
    })
  }
  after { StripeMock.stop }
  
  it 'is sucessful' do 
    Timecop.freeze("2021-09-29T18:19:25Z") do 
      pending("Stripe-mock not recognizing start_date")
      # Create user
      user = create(:user)
      expect(user.inbox).to be_nil
      expect(user.subscriptions.count).to eq(0)

      # Call the right things
      expect(Mail::Recipient).to receive(:build).once.and_call_original
      expect(Mail::CreditTransaction).to receive(:create_monthly_allocations_for_plan!).once.and_call_original

      # Do it!
      Mail::Services::SetupAccount.call(
        user: user,
        plan: :mail_standard,
        stripe_subscription: @stripe_subscription
      )

      user.reload

      # Creates mail inbox
      expect(user.inbox).to be_present
      expect(user.inbox.recipients.count).to eq(1)
      expect(user.inbox.recipients.last.address_en).to eq("ID #{user.id}, Crea Landmark 305, 2-9 Reisenmachi, Hakata Ward, Fukuoka 8120039 Japan")
      expect(user.inbox.recipients.last.address_jp).to eq("〒812-0039 福岡県福岡市博多区冷泉町2-9 クレアランドマーク305-#{user.id}")
    
      # Creates subscription record
      expect(user.subscriptions.count).to eq(1)
      expect(user.subscriptions.last.plan_type).to eq('mail')
      expect(user.subscriptions.last.plan).to eq('mail_standard')
      expect(user.subscriptions.last.stripe_subscription_id).to eq(@stripe_subscription.id)
      expect(user.subscriptions.last.status).to eq('active')
      expect(user.subscriptions.last.billing_started_at.iso8601).to eq('2011-06-20T18:37:18Z')
      expect(user.subscriptions.last.billing_period_started_at).to eq(Time.at(@stripe_subscription.current_period_start))
      expect(user.subscriptions.last.billing_period_ends_at).to eq(Time.at(@stripe_subscription.current_period_end))

      # Allocate credits for mail scans and translation summaries based on plan
      expect(user.inbox.credit_transactions.count).to eq(2)
      credit_transaction_mail_content_scan = user.inbox.credit_transactions.with_credit_type(:mail_content_scan).last
      expect(credit_transaction_mail_content_scan.balance).to eq(60)
      credit_transaction_mail_translation_summary = user.inbox.credit_transactions.with_credit_type(:mail_translation_summary).last
      expect(credit_transaction_mail_translation_summary.balance).to eq(60)
    end
  end

  it 'handles exceptions' do
    pending("Stripe-mock not recognizing start_date")
    # Create user
    user = create(:user)
    expect(user.inbox).to be_nil
    expect(user.subscriptions.count).to eq(0)

    expect(Sentry).to receive(:capture_exception).exactly(2).times

    # Bad Stripe subscription object
    expect { 
      Mail::Services::SetupAccount.call(
        user: user,
        plan: :mail_standard,
        stripe_subscription: nil
      )
    }.to raise_error do |error| 
      expect(error.code).to eq('mail.services.setupAccount')
      expect(error.message).to eq('Encountered error setting up account')
      expect(error.extra[:exception_message]).to include("undefined method `id' for nil:NilClass")
    end

    # Transaction rolls everything back
    expect(user.inbox).to be_nil
    expect(user.subscriptions.count).to eq(0)

    # Invalid plan
    expect { 
      Mail::Services::SetupAccount.call(
        user: user,
        plan: 'invalid',
        stripe_subscription: @stripe_subscription
      )
    }.to raise_error do |error| 
      expect(error.code).to eq('mail.services.setupAccount')
      expect(error.message).to eq('Encountered error setting up account')
      expect(error.extra[:exception_message]).to eq("Validation failed: Plan is not valid for plan type")
    end

    # Transaction rolls everything back
    expect(user.inbox).to be_nil
    expect(user.subscriptions.count).to eq(0)
  end
end