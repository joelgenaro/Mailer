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

require 'rails_helper'

RSpec.describe Assistant::TimeAllocation, type: :model do
  context "Validations" do 
    subject { build(:assistant_time_allocation) }

    it 'source' do 
      # Optional 
      should allow_value(nil).for (:source)
      # Enum
      ['subscription'].each do |value|
        should allow_value(value).for (:source)
      end
      should_not allow_value('bad').for (:source)
    end

    it 'valid_from' do 
      # Required
      should_not allow_value(nil).for(:valid_from)
    end

    it 'valid_to' do 
      # Required
      should_not allow_value(nil).for(:valid_to)
    end

    it "validate_valid_dates" do 
      time_allocation = build(:assistant_time_allocation)

      # Before
      time_allocation.valid_from = Time.now
      time_allocation.valid_to = Time.now - 1.week
      expect(time_allocation.valid?).to eq(false)
      expect(time_allocation.errors.full_messages).to include("Valid to must be at least one day after valid from")

      # Same day
      time_allocation.valid_from = Time.now
      time_allocation.valid_to = Time.now
      expect(time_allocation.valid?).to eq(false)
      expect(time_allocation.errors.full_messages).to include("Valid to must be at least one day after valid from")

      # After
      time_allocation.valid_from = Time.now
      time_allocation.valid_to = Time.now + 1.day
      expect(time_allocation.valid?).to eq(true)
    end
  end

  context "Callbacks" do 
    it "after_commit_calculate_balance_seconds" do 
      # On create, update and destroy
      user = create(:user)
      subscription = create(:subscription, :with_plan_assistant, user: user)
      expect(user.task_list).to receive(:calculate_balance_seconds!).exactly(3).times

      time_allocation = Assistant::TimeAllocation.create!(user: user, minutes: 180, valid_from: Time.now, valid_to: Time.now + 30.days)
      expect(time_allocation.persisted?).to eq(true)

      time_allocation.update(minutes: 57)

      time_allocation.destroy
      expect(time_allocation.destroyed?).to eq(true)
    end
  end
end
