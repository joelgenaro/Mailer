require "rails_helper"
include BasicAuthHelper

RSpec.feature "Sign in", :type => :feature do
    before do 
        StripeMock.start
        @user = create(:user, :with_profile, :with_payment_method)
        @subscription = create(:subscription, :with_plan_mail, user: @user)
        basic_auth_login()
    end

    scenario "Require Sign In" do
        visit app_path
        expect(page).to have_text('You need to sign in or sign up before continuing.')
        expect(page).to have_field("user_email")
        expect(page).to have_field("user_password")
        expect(page).to have_button("Sign In")
        expect(page).to have_link("Forgot password?")
        expect(page).to have_link("Do not have account? Sign up")
    end

    scenario "Valid Sign In" do
        visit new_user_session_path
        fill_in 'user_email', with: @user.email
        fill_in 'user_password', with: @user.password
        click_button("Sign In")
        expect(page).to have_text("Signed in successfully.")
        expect(page).to have_link('Mail')
        expect(page).to have_link('Assistant')
        expect(page).to have_link('Receptionist')
        expect(page).to have_link('Transactions')
        expect(page).to have_link('Settings')
        expect(page).to have_link('Logout')
    end

    scenario "Invalid Sign In" do
        visit new_user_session_path
        fill_in 'user_email', with: "invalid email"
        fill_in 'user_password', with: @user.password
        click_button("Sign In")
        expect(page).to have_text("Invalid Email or password")
        fill_in 'user_email', with: @user.email
        fill_in 'user_password', with: "invalid password"
        click_button("Sign In")
        expect(page).to have_text("Invalid Email or password")
    end
end