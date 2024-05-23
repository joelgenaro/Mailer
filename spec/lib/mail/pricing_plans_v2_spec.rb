require 'rails_helper'

RSpec.describe Mail::PricingPlansV2 do

  # We basically want to check that nothing fundamentally broke
  it 'smoke screen' do 
    expect(Mail::PricingPlansV2.all.class).to eq(Hash)

    expect(Mail::PricingPlansV2.find(:mail_starter)[:title]).to eq('Starter')
    expect(Mail::PricingPlansV2.find('mail_starter')[:title]).to eq('Starter')
    expect(Mail::PricingPlansV2.find(:mail_pro)[:title]).to eq('Pro')
    expect(Mail::PricingPlansV2.find('mail_pro')[:title]).to eq('Pro')
    expect(Mail::PricingPlansV2.find(:unknown)).to be_nil
    expect(Mail::PricingPlansV2.find('unknown')).to be_nil
  end
  
end