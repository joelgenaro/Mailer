require "rails_helper"
include BasicAuthHelper
RSpec.feature "Ja Landing", :type => :feature do
    before do 
        basic_auth_login()
    end

    scenario "visit /ja page" do
        visit root_ja_path
        expect(page).to have_text("価値のある「時間」を創り、 すべての人に柔軟な働き方を。")

        # navigations
        expect(page).to have_link("MailMateとは")
        expect(page).to have_link("機能")
        expect(page).to have_link("料金プラン")
        expect(page).to have_link("ログイン")

        # anchor link sign up
        expect(page).to have_link("サインアップ")

        # sign up plans for buttons
        expect(page).to have_button("申し込む",count: 3)

    end

    scenario "visit to /ja/pricing is redirected to /ja" do
        visit marketing_pricing_ja_path
        expect(current_path).to eql(root_ja_path)

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

    scenario "visit to /pricing" do
        visit marketing_pricing_en_path

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