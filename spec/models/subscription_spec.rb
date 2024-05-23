# == Schema Information
#
# Table name: subscriptions
#
#  id                        :bigint           not null, primary key
#  billing_period_ends_at    :datetime
#  billing_period_started_at :datetime
#  billing_started_at        :datetime
#  legacy_stripe_account     :boolean          default(FALSE)
#  plan                      :string
#  plan_type                 :string
#  status                    :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  stripe_subscription_id    :string
#  user_id                   :bigint
#
# Indexes
#
#  index_subscriptions_on_user_id  (user_id)
#

require 'rails_helper'

RSpec.describe Subscription, type: :model do
  include StripeMockHelper

  context 'Validations' do 
    subject { build(:subscription)  }

    it 'user' do 
      # Required
      should belong_to(:user)
      should_not allow_value(nil).for (:user)
      should_not belong_to(:user).dependent(:destroy)
    end

    it 'payments' do 
      should have_many(:payments).dependent(:destroy)
    end

    it 'plan_type' do 
      # Required 
      should_not allow_value(nil).for (:plan_type)
      # Enum
      ['assistant', 'mail', 'receptionist'].each do |value|
        should allow_value(value).for (:plan_type)
      end
      should_not allow_value('bad').for (:plan_type)
    end

    it 'plan' do 
      # Required
      should_not allow_value(nil).for (:plan)
    end

    it 'status' do 
      # Optional
      should allow_value(nil).for (:status)
      # Enum
      ['active', 'past_due', 'unpaid', 'canceled', 'incomplete', 'incomplete_expired', 'trialing'].each do |value|
        should allow_value(value).for (:status)
      end
      should_not allow_value('bad').for (:status)
    end

    it 'stripe_subscription_id' do 
      # Required
      should_not allow_value(nil).for (:stripe_subscription_id)
      # Unique
      should validate_uniqueness_of(:stripe_subscription_id)
    end

    it 'validate_plan' do 
      # Ignores if no plan_type or plan set yet
      [[nil, nil], ['', ''], ['assistant', nil], [nil, 'assistant_business_entrepreneur']].each do |value|
        subject.plan_type = value[0]
        subject.plan = value[1]
        subject.valid?
        expect(subject.errors.full_messages).to_not include("Plan is not valid for plan type")
      end

      # Not applicable to receptionst plans... for now 
      subject.plan_type = "receptionist"
      subject.plan = "baaad"
      subject.valid?
      expect(subject.errors.full_messages).to_not include("Plan is not valid for plan type")

      # Invalid plan
      ['assistant', 'mail'].each do |plan_type|
        subject.plan_type = plan_type
        subject.plan = "bad"
        subject.valid?
        expect(subject.errors.full_messages).to include("Plan is not valid for plan type")
      end

      # Valid plan
      [['assistant', 'assistant_business_entrepreneur'], ['mail', 'mail_pro']].each do |item|
        subject.plan_type = item[0]
        subject.plan = item[1]
        subject.valid?
        expect(subject.errors.full_messages).to_not include("Plan is not valid for plan type")
      end

      # Can't mix and match
      subject.plan_type = 'mail'
      subject.plan = "assistant_business_entrepreneur"
      subject.valid?
      expect(subject.errors.full_messages).to include("Plan is not valid for plan type")

      # Can skip this validation (eg for legacy plans)
      subject.plan_type = "assistant"
      subject.plan = "assistant_personal" # This is a V1 pricing plan name
      expect(subject._skip_validate_plan).to be_nil
      subject.valid?
      expect(subject.errors.full_messages).to include("Plan is not valid for plan type")

      subject._skip_validate_plan = true
      subject.valid?
      expect(subject.errors.full_messages).to_not include("Plan is not valid for plan type")

      subject._skip_validate_plan = false
      subject.valid?
      expect(subject.errors.full_messages).to include("Plan is not valid for plan type")
    end

    it 'validate_one_plan_type_per_user' do 
      # User has no other subscriptions
      user = create(:user)
      expect(user.subscriptions.count).to eq(0)

      # Can create subscription of other type 
      subscription_mail = create(:subscription, :with_plan_mail, :with_status_active, user: user)
      expect(subscription_mail.valid?).to eq(true)
      expect(user.subscriptions.count).to eq(1)

      # Create assistant subscription
      subscription_assistant_1 = create(:subscription, :with_plan_assistant, :with_status_active, user: user)
      expect(subscription_assistant_1.valid?).to eq(true)
      expect(user.subscriptions.count).to eq(2)

      # Doesn't run without plan_type or user
      subscription_assistant_2 = build(:subscription, :with_status_active)
      subscription_assistant_2.stripe_subscription_id = 'sub_oct2021assist'
      subscription_assistant_2.plan = 'assistant_individual_executive'
      subscription_assistant_2.valid?
      expect(subscription_assistant_2.errors.full_messages).to_not include('User already has subscription with this plan type')
      subscription_assistant_2.user = user
      subscription_assistant_2.valid?
      expect(subscription_assistant_2.errors.full_messages).to_not include('User already has subscription with this plan type')
      subscription_assistant_2.user = nil
      subscription_assistant_2.plan_type = :assistant
      subscription_assistant_2.valid?
      expect(subscription_assistant_2.errors.full_messages).to_not include('User already has subscription with this plan type')
      subscription_assistant_2.user = user
      subscription_assistant_2.valid?
      expect(subscription_assistant_2.errors.full_messages).to include('User already has subscription with this plan type')

      # Status doesn't affect
      subscription_assistant_1.update(status: :canceled)
      subscription_assistant_2.valid?
      expect(subscription_assistant_2.errors.full_messages).to include('User already has subscription with this plan type')

      # Will work if other doesn't exist
      subscription_assistant_1.destroy
      expect(user.subscriptions.count).to eq(1)
      expect(subscription_assistant_2.valid?).to eq(true)
      expect(subscription_assistant_2.save).to eq(true)
      expect(user.subscriptions.count).to eq(2)
    end
  end

  context 'Stripe' do 
    it 'update_from_stripe_subscription!' do 
      pending("Stripe-mock not recognizing start_date")
      StripeMock.start 
      stripe_helper = StripeMock.create_test_helper
      stripe_helper.create_plan({
        id: 'assistant_individual_executive', 
        product: stripe_helper.create_product.id, 
        amount: 20000, 
        currency: 'jpy'
      })
      stripe_customer = Stripe::Customer.create(source: stripe_helper.generate_card_token, currency: 'jpy')
      Timecop.freeze("Fri, 15 Oct 2021 18:00:01 UTC +00:00") do 
        # Updates from Stripe subscription, 
        # and handles subscriptions with legacy plans
        active_to_canceled_stripe = Stripe::Subscription.create({
          customer: stripe_customer.id,
          items: [{ plan: 'assistant_individual_executive' }]
        })
        active_to_canceled_stripe.delete
        active_to_canceled = create(:subscription, :with_plan_assistant, :with_status_active, stripe_subscription_id: active_to_canceled_stripe.id)

        legacy_stripe = Stripe::Subscription.create({
          customer: stripe_customer.id,
          items: [{ plan: 'assistant_individual_executive' }]
        })
        legacy = build(:subscription, :with_plan_assistant, :with_status_active, stripe_subscription_id: legacy_stripe.id)
        legacy._skip_validate_plan = true
        legacy.plan = 'assistant_personal' # V1 plan
        legacy.save!
        legacy._skip_validate_plan = nil # Back to default value
        expect(legacy._skip_validate_plan).to be_nil

        expect(active_to_canceled.status).to eq('active')
        expect(active_to_canceled.billing_started_at).to eq(Time.parse("Sun, 02 May 2021 11:11:15 UTC +00:00"))
        expect(active_to_canceled.billing_period_started_at).to eq(Time.parse("Thu, 02 Sep 2021 11:11:15 UTC +00:00"))
        expect(active_to_canceled.billing_period_ends_at).to eq(Time.parse("Sat, 02 Oct 2021 11:11:15 UTC +00:00"))
        expect(active_to_canceled.updated_at).to be_within(1.minute).of(Time.now)

        expect(legacy.status).to eq('active')
        expect(legacy.billing_started_at).to eq(Time.parse("Sun, 02 May 2021 11:11:15 UTC +00:00"))
        expect(legacy.billing_period_started_at).to eq(Time.parse("Thu, 02 Sep 2021 11:11:15 UTC +00:00"))
        expect(legacy.billing_period_ends_at).to eq(Time.parse("Sat, 02 Oct 2021 11:11:15 UTC +00:00"))
        expect(legacy.updated_at).to be_within(1.minute).of(Time.now)

        Timecop.travel(10.minutes)
        expect(active_to_canceled.updated_at).to_not be_within(1.minute).of(Time.now)
        
        stripe_subscription = active_to_canceled.update_from_stripe_subscription!
        expect(stripe_subscription.class).to eq(Stripe::Subscription)
        expect(stripe_subscription.id).to eq(active_to_canceled_stripe.id)
        expect(active_to_canceled.status).to eq('canceled')
        expect(active_to_canceled.billing_started_at).to eq(Time.parse("Mon, 20 Jun 2011 18:37:18 UTC +00:00"))
        expect(active_to_canceled.billing_period_started_at).to eq(Time.parse("Fri, 15 Oct 2021 18:00:01 UTC +00:00"))
        expect(active_to_canceled.billing_period_ends_at).to eq(Time.parse("Fri, 15 Nov 2021 18:00:01 UTC +00:00"))
        expect(active_to_canceled.updated_at).to be_within(1.minute).of(Time.now)

        stripe_subscription = legacy.update_from_stripe_subscription!
        expect(stripe_subscription.class).to eq(Stripe::Subscription)
        expect(stripe_subscription.id).to eq(legacy_stripe.id)
        expect(legacy.status).to eq('active')
        expect(legacy.billing_started_at).to eq(Time.parse("Mon, 20 Jun 2011 18:37:18 UTC +00:00"))
        expect(legacy.billing_period_started_at).to eq(Time.parse("Fri, 15 Oct 2021 18:00:01 UTC +00:00"))
        expect(legacy.billing_period_ends_at).to eq(Time.parse("Fri, 15 Nov 2021 18:00:01 UTC +00:00"))
        expect(legacy.updated_at).to be_within(1.minute).of(Time.now)
      end
      StripeMock.stop
    end
  end
end
