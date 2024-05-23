require 'rails_helper'

# We're use Assistant::PricingPlansV2 to test, as implements the class
RSpec.describe Billing::PricingPlans do

  context 'self.all' do 
    it 'not implemented' do 
      expect { Billing::PricingPlans.all }.to raise_error(StandardError, "Implement me!")
    end

    it 'implemented' do 
      expect(Assistant::PricingPlansV2.all.class).to eq(Hash)
    end
  end

  it 'self.find' do 
    expect(Assistant::PricingPlansV2.find(:assistant_individual_executive)[:title]).to eq('Executive')
    expect(Assistant::PricingPlansV2.find('assistant_individual_executive')[:title]).to eq('Executive')
    expect(Assistant::PricingPlansV2.find(:assistant_business_team)[:title]).to eq('Team')
    expect(Assistant::PricingPlansV2.find('assistant_business_team')[:title]).to eq('Team')
    expect(Assistant::PricingPlansV2.find(:unknown)).to be_nil
    expect(Assistant::PricingPlansV2.find('unknown')).to be_nil
  end

  it 'self.find!' do 
    expect(Assistant::PricingPlansV2.find!(:assistant_individual_executive)[:title]).to eq('Executive')
    expect(Assistant::PricingPlansV2.find!('assistant_individual_executive')[:title]).to eq('Executive')
    expect(Assistant::PricingPlansV2.find!(:assistant_business_team)[:title]).to eq('Team')
    expect(Assistant::PricingPlansV2.find!('assistant_business_team')[:title]).to eq('Team')
    expect{ Assistant::PricingPlansV2.find!(:unknown) }.to raise_error(Billing::Error::PlanNotFound)
    expect{ Assistant::PricingPlansV2.find!('unknown') }.to raise_error(Billing::Error::PlanNotFound)
  end

  it 'self.env_for_secret_key' do 
    expect(ENV['STRIPE_SECRET_KEY']).to eq('sk_test_51IJyvDDWPLY96bTNPXY7c_NOT_REAL')

    # Live
    ClimateControl.modify(STRIPE_SECRET_KEY: 'sk_live_53ewoewewewTNPXY7c_NOT_REAL') { expect(Assistant::PricingPlansV2.env_for_secret_key).to eq(:live) }

    # Test
    ClimateControl.modify(STRIPE_SECRET_KEY: 'sk_test_51IJyvDDWPLY96bTNPXY7c_NOT_REAL') { expect(Assistant::PricingPlansV2.env_for_secret_key).to eq(:test) }
    ClimateControl.modify(STRIPE_SECRET_KEY: 'lolwut') { expect(Assistant::PricingPlansV2.env_for_secret_key).to eq(:test) }

    expect(ENV['STRIPE_SECRET_KEY']).to eq('sk_test_51IJyvDDWPLY96bTNPXY7c_NOT_REAL') # Ensure is set back
  end

  it 'self.find_by_stripe_price_id' do 
    expect(ENV['STRIPE_SECRET_KEY']).to eq('sk_test_51IJyvDDWPLY96bTNPXY7c_NOT_REAL')

    # Live 
    ClimateControl.modify(STRIPE_SECRET_KEY: 'sk_live_53ewoewewewTNPXY7c_NOT_REAL') do 
      key, plan = Assistant::PricingPlansV2.find_by_stripe_price_id('price_1LvKYEHbG97ysJgwpk484XlA')
      expect(key).to eq(:assistant_individual_executive) 
      expect(plan[:title]).to eq('Executive') 

      key, plan = Assistant::PricingPlansV2.find_by_stripe_price_id('price_1LwGLOHbG97ysJgwQpbhcicV')
      expect(key).to eq(:assistant_business_entrepreneur) 
      expect(plan[:title]).to eq('Entrepreneur') 
    end

    # Test
    ClimateControl.modify(STRIPE_SECRET_KEY: 'sk_test_51IJyvDDWPLY96bTNPXY7c_NOT_REAL') do 
      key, plan = Assistant::PricingPlansV2.find_by_stripe_price_id('price_1LxN1wHbG97ysJgw7ioyj3u1')
      expect(key).to eq(:assistant_individual_executive) 
      expect(plan[:title]).to eq('Executive') 
      
      key, plan = Assistant::PricingPlansV2.find_by_stripe_price_id('price_1LxN2pHbG97ysJgwwJQETgqs')
      expect(key).to eq(:assistant_business_entrepreneur) 
      expect(plan[:title]).to eq('Entrepreneur') 
    end

    # Not Found
    expect{ Assistant::PricingPlansV2.find_by_stripe_price_id('') }.to raise_error(Billing::Error::PlanNotFound)
    expect{ Assistant::PricingPlansV2.find_by_stripe_price_id('bad')}.to raise_error(Billing::Error::PlanNotFound)

    expect(ENV['STRIPE_SECRET_KEY']).to eq('sk_test_51IJyvDDWPLY96bTNPXY7c_NOT_REAL') # Ensure is set back
  end
  
end