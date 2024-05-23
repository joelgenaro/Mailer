# == Schema Information
#
# Table name: growth_referrers
#
#  id          :bigint           not null, primary key
#  code        :string
#  conversions :integer          default(0)
#  parameters  :jsonb
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_growth_referrers_on_code  (code)
#

FactoryBot.define do
  factory :growth_referrer, class: 'Growth::Referrer' do
    code { "something" }
    conversions { 0 }
    parameters { nil }

    trait (:with_code_cic) do 
      code { "cic" }
      parameters {{
        lifetime_stripe_coupon_id: 'wDxLIFETIME',
        month_stripe_coupon_id: '5J3MONTH',
      }}
    end
  end
end
