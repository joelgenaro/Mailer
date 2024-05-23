# == Schema Information
#
# Table name: time_allocations
#
#  id         :bigint           not null, primary key
#  minutes    :integer
#  source     :string
#  valid_from :datetime
#  valid_to   :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint
#
# Indexes
#
#  index_time_allocations_on_user_id  (user_id)
#

FactoryBot.define do
  factory :assistant_time_allocation, class: 'Assistant::TimeAllocation' do
    association :user, factory: :user
    valid_from { Time.now }
    valid_to { Time.now + 30.days }
    minutes { 180 }
    source { :subscription }
  end
end
