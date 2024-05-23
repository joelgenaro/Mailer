# == Schema Information
#
# Table name: users
#
#  id                                   :bigint           not null, primary key
#  auto_bill_limit_amount               :integer          default(30000), not null
#  auto_open_mail                       :boolean          default(FALSE)
#  card_last4                           :string
#  card_type                            :string
#  closed_at                            :datetime
#  current_sign_in_at                   :datetime
#  current_sign_in_ip                   :inet
#  email                                :string           default(""), not null
#  encrypted_password                   :string           default(""), not null
#  isautobillenabled                    :boolean
#  last_sign_in_at                      :datetime
#  last_sign_in_ip                      :inet
#  legacy_stripe_account                :boolean          default(FALSE)
#  locale                               :string
#  onboarding_address_verification_code :string
#  onboarding_state                     :string
#  plan                                 :string
#  remember_created_at                  :datetime
#  request_mail                         :string
#  reset_password_sent_at               :datetime
#  reset_password_token                 :string
#  sign_in_count                        :integer          default(0), not null
#  utm_campaign                         :string
#  utm_medium                           :string
#  utm_source                           :string
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#  growth_referrer_id                   :bigint
#  stripe_customer_id                   :string
#  stripe_payment_method_id             :string
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_growth_referrer_id    (growth_referrer_id)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (growth_referrer_id => growth_referrers.id)
#

require 'rails_helper'

RSpec.describe User, type: :model do

  context 'Relationships' do 
    it 'growth_referrer' do 
      should belong_to(:growth_referrer).optional
      should_not belong_to(:growth_referrer).dependent(:destroy)
    end
  end
end
