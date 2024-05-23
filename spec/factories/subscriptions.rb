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

FactoryBot.define do
  factory :subscription do
    association :user, factory: :user

    ###
    # MARK: Plans
    # Might be handy to look at the account setup code too,
    # to ensure you have everything for the plan to work 
    # properly: app/lib/setup_account.rb

    trait :with_plan_assistant do 
      plan_type { :assistant }
      plan { :assistant_individual_executive }
      stripe_subscription_id { "sub_K4Zassistant#{rand(1...9999999)}" }
      billing_started_at { Time.parse("2021-05-02T11:11:15Z") }
      billing_period_started_at { Time.parse("2021-09-02T11:11:15Z") }
      billing_period_ends_at { Time.parse("2021-10-02T11:11:15Z") }

      after(:create) do |subscription|
        create(:assistant_task_list, user: subscription.user)
      end
    end

    trait :with_plan_mail do 
      plan_type { :mail }
      plan { :mail_standard }
      stripe_subscription_id { "sub_DBZmail#{rand(1...9999999)}" }
      billing_started_at { Time.parse("2021-05-02T11:11:15Z") }
      billing_period_started_at { Time.parse("2021-09-02T11:11:15Z") }
      billing_period_ends_at { Time.parse("2021-10-02T11:11:15Z") }
      
      after(:create) do |subscription|
        create(:mail_inbox, user: subscription.user)
      end
    end

    ###
    # MARK: Statuses

    trait :with_status_active do 
      status { :active }
    end

    trait :with_status_past_due do 
      status { :past_due }
    end

    trait :with_status_canceled do 
      status { :canceled  }
    end

  end
end
