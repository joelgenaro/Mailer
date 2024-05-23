# == Schema Information
#
# Table name: reminders
#
#  id              :bigint           not null, primary key
#  email_sent_at   :datetime
#  kind            :string
#  remindable_type :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  remindable_id   :bigint
#
# Indexes
#
#  index_reminders_on_remindable_type_and_remindable_id  (remindable_type,remindable_id)
#

FactoryBot.define do
  factory :reminder do
    
  end
end
