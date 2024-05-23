# == Schema Information
#
# Table name: payment_methods
#
#  id                       :bigint           not null, primary key
#  card_last4               :string
#  card_type                :string
#  default                  :boolean          default(FALSE)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  stripe_payment_method_id :string
#  user_id                  :bigint
#
# Indexes
#
#  index_payment_methods_on_user_id  (user_id)
#

FactoryBot.define do
  factory :payment_method do
    association :user, factory: :user
    card_last4 { '4242' }
    card_type { 'Visa' }
    default { true }
    stripe_payment_method_id { 'pm_xYz123' }
  end
end
