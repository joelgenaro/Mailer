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

require 'rails_helper'

RSpec.describe PaymentMethod, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
