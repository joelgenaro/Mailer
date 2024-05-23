require "rails_helper"
include BasicAuthHelper

RSpec.feature "General settings", :type => :feature do
    before do 
        StripeMock.start
        @user = create(:user, :with_profile, :with_payment_method)
        @mail_subscription = create(:subscription, :with_plan_mail, user: @user)
        @assistant_subscription = create(:subscription, :with_plan_assistant, user: @user)
        basic_auth_login()
        login_as(@user)
        visit settings_path
    end

    scenario "visit general settings" do
        expect(page).to have_text("Account")
        expect(page).to have_text("Assistant Preferences")
        expect(page).to have_text("Auto-Open Mail")
        expect(page).to have_text("Address in English")
        expect(page).to have_text("Your Virtual Addresses")
        expect(page).to have_text @user.inbox.recipients.first.address_en
        expect(page).to have_text("Address in Japanese")
        expect(page).to have_text @user.inbox.recipients.first.address_jp
        expect(page).to have_css(".settings__address__copy-btn", count: 3)
    end

    scenario "Switch Language" do
        # change to japanese
        find('#user_locale').find(:xpath, 'option[2]').select_option
        find('#language_change_btn').click
        expect(page).to have_text("アカウント情報")
        expect(page).to have_text("Language has been updated")
        # change to english
        find('#user_locale').find(:xpath, 'option[1]').select_option
        first(".settings__card__section").click_button("変更を保存")
        expect(page).to have_text("Account")
        expect(page).to have_text("Language has been updated")
    end

    scenario "Change Email" do
        expect(page).to have_field('user_email', with: @user.email)

        # invalid updates
        @another_user = create(:user)
        fill_in "user_email", with: @another_user.email
        find('#email_change_btn').click
        expect(page).to have_text("Failed to update your email address. Please check for errors and try again.")
        expect(page).to have_text("Another account already exists with this email")

        # valid update
        fill_in "user_email", with: "valid@test.com"
        find('#email_change_btn').click
        expect(page).to have_text("Your email address has been updated")
        expect(page).to have_field('user_email', with: "valid@test.com")
    end

    scenario "Change Password" do
        expect(page).to have_field('user_current_password')
        expect(page).to have_field('user_password')
        expect(page).to have_field('user_password_confirmation')
        # invalid updates
        fill_in "user_password", with: "password!"
        click_button("Change Password")
        expect(page).to have_text("The passwords you've entered do not match")
        expect(page).to have_text("can't be blank")
        expect(page).to have_text("doesn't match Password")

        fill_in "user_password", with: "123"
        fill_in "user_password_confirmation", with: "123"
        click_button("Change Password")
        expect(page).to have_text("The passwords you've entered do not match")
        expect(page).to have_text("can't be blank")
        expect(page).to have_text("Please enter a password with at least 6 characters")

        fill_in "user_password", with: "password!"
        fill_in "user_password_confirmation", with: "password!"
        click_button("Change Password")
        expect(page).to have_text("The passwords you've entered do not match")
        expect(page).to have_text("can't be blank")

        # valid try
        fill_in "user_current_password", with: @user.password
        fill_in "user_password", with: "password!"
        fill_in "user_password_confirmation", with: "password!"
        click_button("Change Password")
        expect(page).to have_text("Your password has been updated")
    end

    scenario "Change Request Mail address" do
        expect(page).to have_field('user_request_mail', with: @user.request_mail)

        # invalid updates
        @another_user = create(:user)
        fill_in "user_request_mail", with: @another_user.request_mail
        find('#request_mail_change_btn').click
        expect(page).to have_text("Failed to update your request mail address. Please check for errors and try again.")
        expect(page).to have_text("Another account already exists with this request mail address")

        # valid update
        fill_in "user_request_mail", with: "test123"
        find('#request_mail_change_btn').click
        expect(page).to have_text("Your request mail address has been updated")
        expect(page).to have_field('user_request_mail', with: "test123")
    end

    scenario "Assistant overtime preference" do
        expect(page).to have_unchecked_field 'task_list[allows_overtime]'

        # check
        check 'task_list[allows_overtime]'
        find('#assistant_preferences_btn').click
        expect(page).to have_text("Your assistant preferences have been updated.")
        expect(page).to have_checked_field 'task_list[allows_overtime]'

        # uncheck
        uncheck 'task_list[allows_overtime]'
        find('#assistant_preferences_btn').click
        expect(page).to have_text("Your assistant preferences have been updated.")
        expect(page).to have_unchecked_field 'task_list[allows_overtime]'
    end

    scenario "Auto open mail" do
        expect(page).to have_unchecked_field 'inbox[auto_open_mail]'

        # check
        check 'inbox[auto_open_mail]'
        find('#auto_open_mail_btn').click
        expect(page).to have_text("Your auto-open preferences have been updated.")
        expect(page).to have_checked_field 'inbox[auto_open_mail]'

        # uncheck
        uncheck 'inbox[auto_open_mail]'
        find('#auto_open_mail_btn').click
        expect(page).to have_text("Your auto-open preferences have been updated.")
        expect(page).to have_unchecked_field 'inbox[auto_open_mail]'
    end

    scenario "update Notify shred preferences" do
        # should be checked by default
        expect(page.find("input#inbox_notify_shred")).to be_checked

        # test uncheck
        uncheck 'inbox[notify_shred]'
        find('#notify_shred_btn').click
        expect(page).to have_text("Your shredded notification email preferences have been updated.")
        expect(page.find("input#inbox_notify_shred")).not_to be_checked
        expect(Mail::Inbox.find(@user.inbox.id).notify_shred).to eq(false)

        # test check
        check 'inbox[notify_shred]'
        find('#notify_shred_btn').click
        expect(page).to have_text("Your shredded notification email preferences have been updated.")
        expect(page.find("input#inbox_notify_shred")).to be_checked
        expect(Mail::Inbox.find(@user.inbox.id).notify_shred).to eq(true)
    end
end
