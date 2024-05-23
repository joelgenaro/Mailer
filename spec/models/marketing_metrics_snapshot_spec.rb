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

require 'rails_helper'

RSpec.describe MarketingMetricsSnapshot, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
