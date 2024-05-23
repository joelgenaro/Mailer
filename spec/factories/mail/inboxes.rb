# == Schema Information
#
# Table name: inboxes
#
#  id                                :bigint           not null, primary key
#  auto_open_mail                    :boolean          default(FALSE)
#  auto_pay_bills                    :boolean          default(FALSE)
#  auto_pay_limit_amount             :integer          default(30000), not null
#  auto_pay_limit_is_unlimited       :boolean          default(FALSE)
#  credits_balance_last_processed_at :datetime
#  last_checked_at                   :datetime
#  onboarding_status                 :string
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  user_id                           :bigint
#
# Indexes
#
#  index_inboxes_on_user_id  (user_id)
#

FactoryBot.define do
  factory :mail_inbox, class: 'Mail::Inbox' do
    association :user, factory: :user

    auto_open_mail { false }
    auto_pay_bills { false }
    auto_pay_limit_amount { 10000 }
    auto_pay_limit_is_unlimited { false }

    last_checked_at { Time.now }

    after(:create) do |mail_inbox|
      Mail::Recipient.build(mail_inbox).save!
    end
  end
end
