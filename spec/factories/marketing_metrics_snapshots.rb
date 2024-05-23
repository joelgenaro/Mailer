# == Schema Information
#
# Table name: marketing_metrics_snapshots
#
#  id                    :bigint           not null, primary key
#  consultation_requests :integer
#  data                  :jsonb
#  facebook_fans         :integer
#  get_response_contacts :integer
#  instagram_followers   :integer
#  linkedin_followers    :integer
#  twitter_followers     :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

FactoryBot.define do
  factory :marketing_metrics_snapshot do
    data { "" }
  end
end
