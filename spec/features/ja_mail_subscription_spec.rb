require "rails_helper"
include BasicAuthHelper
RSpec.feature "Ja Mail Subscription", :type => :feature do
    before do 
        @user = create(:user, :with_profile, :with_payment_method)
        @subscription = create(:subscription, :with_plan_assistant, user: @user)
        basic_auth_login()
        login_as(@user)
    end

    scenario "ja user not subscribed to mail service visit subscription page" do
        @user.update(locale: 'ja')
        visit mails_path
        expect(page).to have_text("You're not subscribed to our mail service")
        click_on("Get access to MailMate Mail")
        # ja pricing plans
        expect(page).to have_text("料金プラン")
        expect(page).to have_text("スタンダード") # standard
        expect(page).to have_text("¥ 1,500 /月")
        expect(page).to have_text("プレミアム") # premium
        expect(page).to have_text("¥ 3,800 /月")
        expect(page).to have_text("ビジネス") # business
        expect(page).to have_text("¥ 9,800 /月")
        # no en pricing plans
        expect(page).not_to have_text('Mail Pricing')
        expect(page).not_to have_text("Starter")
        expect(page).not_to have_text("¥3,800p/mo")
        expect(page).not_to have_text("Basic")
        expect(page).not_to have_text("¥9,800p/mo")
        expect(page).not_to have_text("Standard")
        expect(page).not_to have_text("¥28,000p/mo")
        expect(page).not_to have_text("Pro")
        expect(page).not_to have_text("¥88,000p/mo")
    end

    scenario "en user not subscribed to mail service visit subscription page" do
        @user.update(locale: 'en')
        visit mails_path
        expect(page).to have_text("You're not subscribed to our mail service")
        click_on("Get access to MailMate Mail")
         # en pricing plans
         expect(page).to have_text('Mail Pricing')
         expect(page).to have_text("Starter")
         expect(page).to have_text("¥3,800p/mo")
         expect(page).to have_text("Basic")
         expect(page).to have_text("¥9,800p/mo")
         expect(page).to have_text("Standard")
         expect(page).to have_text("¥28,000p/mo")
         expect(page).to have_text("Pro")
         expect(page).to have_text("¥88,000p/mo")
         # no ja pricing plans
         expect(page).not_to have_text("料金プラン")
         expect(page).not_to have_text("スタンダード") # standard
         expect(page).not_to have_text("¥ 1,500 /月")
         expect(page).not_to have_text("プレミアム") # premium
         expect(page).not_to have_text("¥ 3,800 /月")
         expect(page).not_to have_text("ビジネス") # business
         expect(page).not_to have_text("¥ 9,800 /月")
    end
end