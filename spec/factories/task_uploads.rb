# == Schema Information
#
# Table name: task_uploads
#
#  id                :bigint           not null, primary key
#  file_content_type :string
#  file_file_name    :string
#  file_file_size    :bigint
#  file_updated_at   :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  task_id           :bigint
#
# Indexes
#
#  index_task_uploads_on_task_id  (task_id)
#
# Foreign Keys
#
#  fk_rails_...  (task_id => tasks.id)
#

FactoryBot.define do
  factory :task_upload do
    task { nil }
  end
end
