require "rails_helper"
include BasicAuthHelper

RSpec.feature "Invoices settings", :type => :feature do
    before do 
        StripeMock.start
        @user = create(:user, :with_profile, :with_payment_method)
        @mail_subscription = create(:subscription, :with_plan_mail, user: @user)
        @assistant_subscription = create(:subscription, :with_plan_assistant, user: @user)
        basic_auth_login()
        login_as(@user)
        visit settings_path
        click_link("Invoices")
    end

    scenario "visit invoices settings" do
        expect(page).to have_text("Invoices")
        expect(page).to have_text("No Invoices")
        expect(page).to have_select('month',selected: Date.current.strftime('%B %Y')) 
    end
end
