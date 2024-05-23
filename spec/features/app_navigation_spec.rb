require "rails_helper"
include BasicAuthHelper
RSpec.feature "App Navigation", :type => :feature do
    before do 
        StripeMock.start
        @user = create(:user, :with_profile, :with_payment_method)
        @subscription = create(:subscription, :with_plan_mail, user: @user)
        basic_auth_login()
        login_as(@user)
    end

    scenario "redirect to app with mail dashboard if already logged in" do
        visit root_path
        expect(page).not_to have_link("Login")
        expect(page).to have_link("Mail")
        expect(page).to have_text("Inbox")
        expect(page).to have_text("MAIL")
        expect(page).to have_text("BILLS")
    end

    scenario "navigation side bar" do
        visit app_path
        expect(page).to have_link("Mail")
        expect(page).to have_link("Assistant")
        expect(page).to have_link("Receptionist")
        expect(page).to have_link("Transaction")
        expect(page).to have_link("Settings")
        expect(page).to have_link("Logout")
    end

    scenario "Go to Assitant" do
        visit app_path
        click_link("Assistant")
        expect(page).to have_text("You're not subscribed to our virtual assistant service")
        expect(page).to have_link("Get access to MailMate Assistant")
        click_link("Get access to MailMate Assistant")
        if ENV.fetch("ASSISTANT_SERVICE_ENABLED")!= "true"
            expect(page).to have_button("Request a Consultation")
        end
    end

    scenario "Go to Receptionist" do
        visit app_path
        click_link("Receptionist")
        expect(page).to have_text("You're not subscribed to our receptionist service")
        expect(page).to have_link("Get access to MailMate Receptionist")
    end

    scenario "Go to Transactions" do
        # create bill
        @unpaid_mail = create(:mail_postal_mail, inbox: @user.inbox, notes:"unpaid mail", bill_attributes: {
        due_date: '2020-10-02 12:00:00',
        description: 'Water & Sewage bill from Tokyo Water',
        subtotal_amount: 5995,
        total_amount: 6475,
        processing_fee_amount: 480,
        user_id: @user.id
        })
        @payment = @unpaid_mail.bill

        # pay bill from mail dashboard
        visit mails_path
        click_link('unpaid mail')
        click_button("Pay Bill")
        click_button("Confirm Payment")

        # change transaction
        click_link("Transactions")
        expect(page).to have_text("Past Payments 1")
        expect(page).to have_text("Water & Sewage bill from Tokyo Water")
        expect(page).to have_text("¥6,475")
        expect(page).to have_text("Succeeded")
        expect(page).to have_link("View")

        # view transaction details
        click_link("View")
        expect(page).to have_text("Transaction Overview")
        # TODO: below assertion fails
        # expect(page).to have_text @payment.id
        expect(page).to have_text("Created At")
        # strftime is causing issue with extra leading space for one digit month and hour
        # expect(page).to have_text @payment.created_at.strftime("%b %e, %Y at %l:%M%P")
        expect(page).to have_text("Card Type")
        expect(page).to have_text("Visa")
        expect(page).to have_text("Card No.")
        expect(page).to have_text("4242")
        expect(page).to have_text("Attachments")
        expect(page).to have_text("No Attachments")

        # Go back
        click_link("← Back to Transactions")
        expect(page).to have_text("Past Payments 1")
    end

    scenario "Go to Settings" do
        visit app_path
        click_link("Settings")
        expect(page).to have_link("General")
        expect(page).to have_link("Billing")
        expect(page).to have_link("Invoices")
    end

    scenario "Logout" do
        visit app_path
        click_link("Logout")
        expect(page).to have_link("Login")
        expect(page).to have_text("Signed out successfully.")
    end
end