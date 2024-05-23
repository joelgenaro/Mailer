# == Schema Information
#
# Table name: tasks
#
#  id           :bigint           not null, primary key
#  completed_at :datetime
#  due_at       :datetime
#  label        :string
#  notes        :string
#  request_by   :string
#  state        :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  task_list_id :bigint
#  user_id      :bigint
#
# Indexes
#
#  index_tasks_on_task_list_id  (task_list_id)
#  index_tasks_on_user_id       (user_id)
#

FactoryBot.define do
  factory :assistant_task, class: 'Assistant::Task' do
    association :task_list, factory: :assistant_task_list
    label { 'Visa research' }

    trait(:completed) do 
      state { 'complete' }
      completed_at { Time.now }
    end
  end
end
