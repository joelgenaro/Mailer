# == Schema Information
#
# Table name: transactions
#
#  id                       :bigint           not null, primary key
#  description              :string
#  source_type              :string
#  state                    :string
#  total_amount             :integer          default(0), not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  source_id                :bigint
#  stripe_payment_intent_id :string
#  user_id                  :bigint
#
# Indexes
#
#  index_transactions_on_source_type_and_source_id  (source_type,source_id)
#  index_transactions_on_user_id                    (user_id)
#

FactoryBot.define do
  factory :transaction do
    
  end
end
