# == Schema Information
#
# Table name: mail_credit_transactions
#
#  id          :bigint           not null, primary key
#  amount      :integer
#  balance     :integer
#  credit_type :string
#  expires_at  :datetime
#  object_type :string
#  reason      :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  inbox_id    :bigint
#  object_id   :bigint
#
# Indexes
#
#  index_mail_credit_transactions_on_inbox_id                   (inbox_id)
#  index_mail_credit_transactions_on_object_type_and_object_id  (object_type,object_id)
#
# Foreign Keys
#
#  fk_rails_...  (inbox_id => inboxes.id)
#
FactoryBot.define do
  factory :mail_credit_transaction, class: 'Mail::CreditTransaction' do
    association :inbox, factory: :mail_inbox

    object { nil }

    ###
    # MARK: Traits

    # Mail Content Scan
    trait :credit_type__mail_content_scan__income__subscription do 
      credit_type { 'mail_content_scan' }
      reason { 'subscription' }
      amount { 15 }
      expires_at { Time.now + 30.days }
      # TODO: Object should be a payment? Make it optional for this credit reason
    end
    trait :credit_type__mail_content_scan__income__additional_purchase do 
      credit_type { 'mail_content_scan' }
      reason { 'additional_purchase' }
      amount { 3 }
      expires_at { Time.now + 30.days }
      # TODO: Object should be a payment? Make it optional for this credit reason
    end
    trait :credit_type__mail_content_scan__spend__user_request do 
      credit_type { 'mail_content_scan' }
      reason { 'user_request' }
      amount { -1 }
      # TODO: Object should be a postal mail
    end
    trait :credit_type__mail_content_scan__spend__expiration do 
      credit_type { 'mail_content_scan' }
      reason { 'expiration' }
      amount { -5 }
      # TODO: Object should be another mail_credit_transaction
    end

    # Mail Translation Summary
    trait :credit_type__mail_translation_summary__income__subscription do 
      credit_type { 'mail_translation_summary' }
      reason { 'subscription' }
      amount { 15 }
      expires_at { Time.now + 30.days }
      # TODO: Object should be a payment? Make it optional for this credit reason
    end
    trait :credit_type__mail_translation_summary__income__additional_purchase do 
      credit_type { 'mail_translation_summary' }
      reason { 'additional_purchase' }
      amount { 3 }
      expires_at { Time.now + 30.days }
      # TODO: Object should be a payment? Make it optional for this credit reason
    end
    trait :credit_type__mail_translation_summary__spend__user_request do 
      credit_type { 'mail_translation_summary' }
      reason { 'user_request' }
      amount { -1 }
      # TODO: Object should be a postal mail
    end
    trait :credit_type__mail_translation_summary__spend__expiration do 
      credit_type { 'mail_translation_summary' }
      reason { 'expiration' }
      amount { -5 }
      # TODO: Object should be another mail_credit_transaction
    end
  end
end
