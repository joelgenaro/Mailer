require 'rails_helper'

RSpec.describe "marketing/shared/_referrer_banner.html.erb", type: :view do
  before do 
    Growth::Referrer.where(code: 'cic').destroy_all # As codes are unique, start fresh
    @growth_referrer_cic = create(:growth_referrer, :with_code_cic)
  end

  it 'shows nothing if no referrer' do 
    expect(cookies[:tkm_referrer]).to be_nil
    render
    expect(rendered).to eq("")
  end

  it 'only shows on allowed paths' do 
    controller.cookies[:tkm_referrer] = 'cic'

    # Allowed
    [
      '/', '/mail', '/assistant', '/about', '/faq', 
      '/consultation', '/pricing/assistant', '/pricing/mail'
    ].each do |value|
      controller.request.path = value
      expect(render).to eq("  <div class=\"referrer-banner\">\n    CIC Member Discount - 20% off your chosen plan!\n  </div>\n")
    end

    # Not Allowed
    not_allowed = [
      '/blog', '/blog/how-to-make-remote-collaboration-work', '/users/sign_in', 
    ].each do |value|
      controller.request.path = value
      expect(render).to eq("")
    end
  end

  it 'only shows for cic code' do 
    create(:growth_referrer, code: 'different')
    controller.cookies[:tkm_referrer] = 'different'
    controller.request.path = "/"
    expect(controller.current_user).to be_nil
    expect(render).to eq("")
  end

  it 'does not show to existing customers' do 
    user = create(:user)
    sign_in user
    expect(controller.current_user).to eq(user)

    controller.cookies[:tkm_referrer] = 'cic'
    controller.request.path = "/"

    # No subscriptions
    expect(user.subscriptions.count).to eq(0)
    expect(render).to eq("  <div class=\"referrer-banner\">\n    CIC Member Discount - 20% off your chosen plan!\n  </div>\n")

    # Has subscription
    create(:subscription, :with_plan_mail, user: user)
    expect(render).to eq("")
  end

  it 'shows specific text for first 20 conversions' do 
    controller.cookies[:tkm_referrer] = 'cic'
    controller.request.path = "/"
    expect(controller.current_user).to be_nil
    
    expect(@growth_referrer_cic.conversions).to eq(0)
    expect(render).to eq("  <div class=\"referrer-banner\">\n    CIC Member Discount - 20% off your chosen plan!\n  </div>\n")

    @growth_referrer_cic.update(conversions: 19)
    expect(render).to eq("  <div class=\"referrer-banner\">\n    CIC Member Discount - 20% off your chosen plan!\n  </div>\n")
  end

  it 'shows specific text for conversions after the first 20' do 
    controller.cookies[:tkm_referrer] = 'cic'
    controller.request.path = "/"
    expect(controller.current_user).to be_nil

    @growth_referrer_cic.update(conversions: 21)
    expect(render).to eq("  <div class=\"referrer-banner\">\n    CIC Member Discount - 20% off first month!\n  </div>\n")
  end
end
