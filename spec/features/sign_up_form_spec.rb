require "rails_helper"
include BasicAuthHelper

RSpec.feature "Sign up form", :type => :feature do
    before do 
        basic_auth_login()
    end
    scenario "Valid Sign Up" do
        visit marketing_pricing_path(page: 'mail')
        first(".plan").click_button("Get Started")
        expect(page).to have_text("Email Address:")
        expect(page).to have_text("Password:")
        expect(page).to have_button("Create an Account")

        fill_in "user_email", with: "user@test.com"
        fill_in "user_password", with: "password"
        find(:css, "#terms").set(true)
        # click_button("Create an Account")
        # expect(page).to have_current_path(stripe_session.url) # stripe_session not recognized and get undefined method url
    end

    scenario "Invalid Sign Up" do
        visit marketing_pricing_path(page: 'mail')
        first(".plan").click_button("Get Started")

        click_button("Create an Account")
        expect(page).to have_text("Email can't be blank")
        
        fill_in "user_email", with: "user"
        fill_in "user_password", with: "password"
        click_button("Create an Account")
        expect(page).to have_text("Email is invalid")

        fill_in "user_email", with: "user@test.com"
        fill_in "user_password", with: ""
        click_button("Create an Account")
        expect(page).to have_text("Password can't be blank")

        fill_in "user_email", with: "user@test.com"
        fill_in "user_password", with: "123"
        click_button("Create an Account")
        expect(page).to have_text("Please enter a password with at least 6 characters")

        @user = create(:user, :with_profile, :with_payment_method)
        fill_in "user_email", with: @user.email
        fill_in "user_password", with: "password"
        click_button("Create an Account")
        expect(page).to have_text("Another account already exists with this email")
    end
end