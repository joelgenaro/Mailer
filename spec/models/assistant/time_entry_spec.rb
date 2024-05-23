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

require 'rails_helper'

RSpec.describe Assistant::TimeEntry, type: :model do
  context "Callbacks" do 
    it "after_commit_calculate_balance_seconds" do 
      # On create, update and destroy      
      task = create(:assistant_task)
      expect(task.task_list).to receive(:calculate_balance_seconds!).exactly(3).times

      time_entry = Assistant::TimeEntry.create!(task: task, minutes: 10, started_at: Time.now)
      expect(time_entry.persisted?).to eq(true)

      time_entry.update(minutes: 57)

      time_entry.destroy
      expect(time_entry.destroyed?).to eq(true)
    end
  end
end
