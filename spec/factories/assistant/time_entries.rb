# == Schema Information
#
# Table name: time_entries
#
#  id         :bigint           not null, primary key
#  minutes    :integer
#  started_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  task_id    :bigint
#  user_id    :bigint
#
# Indexes
#
#  index_time_entries_on_task_id  (task_id)
#  index_time_entries_on_user_id  (user_id)
#

FactoryBot.define do
  factory :assistant_time_entry, class: 'Assistant::TimeEntry' do
    
  end
end
