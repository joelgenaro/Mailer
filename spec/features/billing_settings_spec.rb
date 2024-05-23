require "rails_helper"
include BasicAuthHelper

RSpec.feature "Billing settings", :type => :feature do
    before do 
        StripeMock.start
        @user = create(:user, :with_profile, :with_payment_method)
        @mail_subscription = create(:subscription, :with_plan_mail, user: @user)
        basic_auth_login()
        login_as(@user)
        visit settings_path
        click_link("Billing")
    end

    scenario "visit billings settings" do
        expect(page).to have_text("Your Payment Card")
        expect(page).to have_text("Automatically Pay Bills")
        expect(page).to have_text("Subscriptions")
    end

    # Stripe redirect not tested
    # scenario "Change card" do
    # end

    scenario "enable/disable auto pay" do
        # enable
        click_button("Enable Auto Pay")
        expect(page).to have_text("Auto-pay has been enabled!")
        expect(page).to have_button("Disable Auto Pay")
        expect(page).to have_text("Enabled: Bills are paid automatically")
        # disable
        click_button("Disable Auto Pay")
        expect(page).to have_text("Auto-pay has been disabled.")
        expect(page).to have_button("Enable Auto Pay")
        expect(page).to have_text("Disabled: Bills are NOT paid automatically")
    end

    scenario "Update threshold" do
        # set to ¥30,000
        find('#auto_pay_threshold').set 30000
        click_button("Update Threshold")
        expect(page).to have_text("Your auto-pay billing threshold has been updated.")
        expect(page).to have_text("¥30,000")
        # set to unlimited
        find('#auto_pay_threshold').set 110000
        click_button("Update Threshold")
        expect(page).to have_text("Your auto-pay billing threshold has been updated.")
        expect(page).to have_text("No Limit", count: 2)
    end

    scenario "Subscriptions" do
        expect(page).to have_text("Plan Type")
        expect(page).to have_text("Status")
        expect(page).to have_text("Actions")
        # Subscriptions rows not generated as there is no stripe subscription in test
    end
end
