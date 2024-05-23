require 'rails_helper'

RSpec.describe Receptionist::SetupAccount do
  it 'setups up an account' do 
    user = create(:user)
    subscription_name = 'receptionist_standard' # From app/lib/receptionist/pricing_plans.rb
    stripe_subscription_id = 'xyz57'

    expect(user.subscriptions.where(plan_type: 'receptionist').count).to eq(0)
    expect(user.receptionist_account).to be_nil

    Receptionist::SetupAccount.new(user, subscription_name, stripe_subscription_id).do

    user.reload

    expect(user.subscriptions.where(plan_type: 'receptionist').count).to eq(1)
    expect(user.subscriptions.where(plan_type: 'receptionist').last.plan).to eq(subscription_name)
    expect(user.subscriptions.where(plan_type: 'receptionist').last.plan_type).to eq('receptionist')
    expect(user.subscriptions.where(plan_type: 'receptionist').last.stripe_subscription_id).to eq(stripe_subscription_id)

    expect(user.receptionist_account.status).to eq('not_setup')
  end
end