# == Schema Information
#
# Table name: task_lists
#
#  id              :bigint           not null, primary key
#  allows_overtime :string
#  balance_seconds :integer          default(0)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :bigint
#
# Indexes
#
#  index_task_lists_on_user_id  (user_id)
#

FactoryBot.define do
  factory :assistant_task_list, class: 'Assistant::TaskList' do
    association :user, factory: :user
    balance_seconds { 100  }
  end
end
