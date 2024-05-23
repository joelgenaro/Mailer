require 'rails_helper'

RSpec.describe Assistant::PricingPlansV2 do

  # We basically want to check that nothing fundamentally broke
  it 'smoke screen' do 
    expect(Assistant::PricingPlansV2.all.class).to eq(Hash)
    
    expect(Assistant::PricingPlansV2.find(:assistant_individual_executive)[:title]).to eq('Executive')
    expect(Assistant::PricingPlansV2.find('assistant_individual_executive')[:title]).to eq('Executive')
    expect(Assistant::PricingPlansV2.find(:assistant_business_team)[:title]).to eq('Team')
    expect(Assistant::PricingPlansV2.find('assistant_business_team')[:title]).to eq('Team')
    expect(Assistant::PricingPlansV2.find(:unknown)).to be_nil
    expect(Assistant::PricingPlansV2.find('unknown')).to be_nil
  end

end