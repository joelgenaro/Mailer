require 'rails_helper'

RSpec.describe Assistant::Services::AdditionalTimePurchasable, type: :service do

  it 'returns correct amount of minutes' do 
    user = create(:user)
    subscription = create(:subscription, :with_plan_assistant, user: user)
    
    # Plan references:
    # assistant_individual_executive = 3 hours additional (180 minutes)
    # assistant_business_team = 7 hours additional (420 minutes)

    # Current subscription period is 2021-09-02 to 2021-10-02,
    # we'll say today is 2021-9-15 (in the middle of period)
    Timecop.freeze('2021-9-15 15:55:00') do
      # With no time allocations, full amount of additional time is available
      expect(user.time_allocations.count).to eq(0)
      expect(Assistant::Services::AdditionalTimePurchasable.call(user: user)).to eq(180)

      # Time allocation from subscription renewal does not affect
      create(:assistant_time_allocation, user: user, source: :subscription, minutes: 5 * 60, valid_from: Time.parse('2021-09-02'), valid_to: Time.parse('2021-10-02'))
      expect(user.time_allocations.count).to eq(1)
      expect(user.time_allocations.last.source.subscription?).to eq(true)
      expect(Assistant::Services::AdditionalTimePurchasable.call(user: user)).to eq(180)

      # Time allocation with no source does not affect
      # TODO/PricingV2: When add rest of sources, this should be swapped out with tests for those
      create(:assistant_time_allocation, user: user, source: nil, minutes: 1 * 60, valid_from: Time.parse('2021-09-03'), valid_to: Time.parse('2021-09-25'))
      expect(user.time_allocations.count).to eq(2)
      expect(user.time_allocations.last.source.nil?).to eq(true)
      expect(Assistant::Services::AdditionalTimePurchasable.call(user: user)).to eq(180)

      # Time allocations purchased before and after billing period don't affect
      create(:assistant_time_allocation, user: user, source: :additional_time_purchase, created_at: Time.parse('2021-09-01 09:00:00'), minutes: 3 * 60, valid_from: Time.parse('2021-09-02'), valid_to: Time.parse('2021-10-02'))
      create(:assistant_time_allocation, user: user, source: :additional_time_purchase, created_at: Time.parse('2021-10-03 09:00:00'), minutes: 3 * 60, valid_from: Time.parse('2021-10-03'), valid_to: Time.parse('2021-11-02'))
      expect(user.time_allocations.count).to eq(4)
      expect(user.time_allocations.last(2)[0].source.additional_time_purchase?).to eq(true)
      expect(user.time_allocations.last(2)[1].source.additional_time_purchase?).to eq(true)
      expect(Assistant::Services::AdditionalTimePurchasable.call(user: user)).to eq(180)
      user.time_allocations.last.destroy # Destroy this one for next month, so doesn't affect later test

      # Purchase 1 hours, 2 hours remaining
      create(:assistant_time_allocation, user: user, source: :additional_time_purchase, minutes: 1 * 60, valid_from: Time.now, valid_to: Time.now + 30.days)
      expect(Assistant::Services::AdditionalTimePurchasable.call(user: user)).to eq(120)

      # Purchase 2 hours, 0 hours remaining
      create(:assistant_time_allocation, user: user, source: :additional_time_purchase, minutes: 2 * 60, valid_from: Time.now, valid_to: Time.now + 30.days)
      expect(Assistant::Services::AdditionalTimePurchasable.call(user: user)).to eq(0)

      # Change plan, more time available
      # assistant_business_team has 7 hours additional, we've purchases 3 hours, so 4 available
      subscription.update(plan: :assistant_business_team)
      expect(Assistant::Services::AdditionalTimePurchasable.call(user: user)).to eq(240)

      # Overpurchase somehow, stays at 0, does not go into negative
      create(:assistant_time_allocation, user: user, source: :additional_time_purchase, minutes: 10 * 60, valid_from: Time.now, valid_to: Time.now + 30.days)
      expect(Assistant::Services::AdditionalTimePurchasable.call(user: user)).to eq(0)

      # Just before period ends, still no additional time available
      Timecop.travel("2021-10-01 11:11:15")
      expect(Assistant::Services::AdditionalTimePurchasable.call(user: user)).to eq(0)

      # Just after next period begins
      Timecop.travel("2021-10-02 12:00:00")
      subscription.update(billing_period_started_at: Time.now, billing_period_ends_at: Time.now + 30.days)
      expect(Assistant::Services::AdditionalTimePurchasable.call(user: user)).to eq(420)
    end
  end

  it 'raises error if user has no assistant subscription' do 
    user = create(:user)
    expect(user.subscriptions.count).to eq(0)

    # No subscriptions
    expect { 
      Assistant::Services::AdditionalTimePurchasable.call(user: user)
    }.to raise_error do |error| 
      expect(error.code).to eq('assistant.services.AdditionalTimePurchasable')
      expect(error.message).to eq('No assistant subscription found')
    end

    # No Assistant subscription
    create(:subscription, :with_plan_mail, user: user)
    expect(user.subscriptions.count).to eq(1)
    expect { 
      Assistant::Services::AdditionalTimePurchasable.call(user: user)
    }.to raise_error do |error| 
      expect(error.code).to eq('assistant.services.AdditionalTimePurchasable')
      expect(error.message).to eq('No assistant subscription found')
    end
  end

end