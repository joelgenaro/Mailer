require "rails_helper"
include BasicAuthHelper

RSpec.feature "Mail dashboard", :type => :feature do
  before do 
    StripeMock.start
    @user = create(:user, :with_profile, :with_payment_method)
    @subscription = create(:subscription, :with_plan_mail, user: @user)
    basic_auth_login()
    login_as(@user)
    Capybara.default_max_wait_time = 5
  end

  scenario "User visit empty dashboard" do
    visit mails_path
    expect(page).to have_text("Nothing to see here! This inbox is currently empty.")
  end

  scenario "User visit mail dashboard with a single mail" do
    @mail = create(:mail_postal_mail, inbox: @user.inbox)
    visit mails_path
    expect(page).to have_css('.mail-inbox__main__list__item__notes', count: 1)
  end

  scenario "search mail list" do
    @mail = create(:mail_postal_mail, inbox: @user.inbox)
    @test_mail1 = create(:mail_postal_mail, inbox: @user.inbox, notes:"test mail 1")
    @test_mail2 = create(:mail_postal_mail, inbox: @user.inbox, notes:"test mail 2")
    visit mails_path
    expect(page).to have_text('test mail',count: 2)
    expect(page).to have_text("Some notes")

    # search test mail
    fill_in 'Search your mail...', with: 'test mail'
    Capybara::RackTest::Form.new(page.driver, find('#mail-search-form').native).submit({})
    expect(page).to have_text('test mail',count: 2)
    expect(page).not_to have_text("Some notes")

    # search some notes with case insensitive
    fill_in 'Search your mail...', with: 'sOme nOTes'
    Capybara::RackTest::Form.new(page.driver, find('#mail-search-form').native).submit({})
    expect(page).not_to have_text('test mail')
    expect(page).to have_text("Some notes")
  end

  scenario "click on mail to view details" do
    @mail = create(:mail_postal_mail, inbox: @user.inbox)
    visit mails_path
    click_link('Some notes')
    expect(page).to have_text('Some notes',count: 2)
    expect(page).to have_text("Received On",count: 2)
    expect(page).to have_text("#{Date.today.strftime("%B %d, %Y")}", count: 2)
    expect(page).to have_button("Archive")
    expect(page).to have_button("Delete")
    expect(page).to have_button("Shred")
    expect(page).to have_button("Forward")
    expect(page.find('.mail-items__item-img', match: :first)['src']).to have_content @mail.mail_items.first.file.filename.to_s
    expect(page).to have_text('Notes')
    expect(page).to have_text('Status')
    expect(page).to have_text('Unopened')
  end

  scenario "request mail opening" do
    @mail = create(:mail_postal_mail, inbox: @user.inbox)
    visit mails_path
    click_link('Some notes')
    expect(page).to have_text("This mail has not yet been opened.")
    click_button('Open It')
    expect(page).to have_text("Your mail is requested to be opened. Your mail will be opened within 24 hours.")
    expect(page).to have_text("Opening")
    click_link('Some notes')
    expect(page).to have_text("You've requested this mail to be opened and it will be updated soon.")
  end

  scenario "archive and unarchive mail" do
    @mail = create(:mail_postal_mail, inbox: @user.inbox)
    visit mails_path

    # Archive
    click_link('Some notes')
    click_button('Archive')
    expect(page).to have_text("Your mail has been archived.")
    expect(page).not_to have_text("Some notes")

    # go to Archived folder and unarchive mail
    click_link('Archived')
    expect(page).to have_text("Some notes")
    click_link('Some notes')
    click_button('Unarchive')
    expect(page).to have_text("Your mail has been unarchived.")
    click_link('Archived')
    expect(page).not_to have_text("Some notes")
  end

  scenario "request mail shredding" do
    @mail = create(:mail_postal_mail, inbox: @user.inbox)
    visit mails_path
    click_link('Some notes')
    expect(page).to have_button('Shred')
    click_button('Shred')
    expect(page).to have_text("Your mail is requested to be shredded. Your mail will be shredded within 24 hours.")
    click_link('Some notes')
    expect(page).not_to have_button('Shred')
  end

  scenario "request mail forwarding" do
    @mail = create(:mail_postal_mail, inbox: @user.inbox)
    visit mails_path
    click_link('Some notes')
    expect(page).to have_button('Forward')
    click_button('Forward')
    expect(page).to have_text("Mail Forward Request")
    fill_in 'address', with: 'test address forwarding'
    click_button('Request Forward')
    expect(page).to have_text("Mail forward successfully requested to 'test address forwarding'. We will be in touch with further details.")
    click_link('Some notes')
    expect(page).to have_text("Forwarding")
    expect(page).to have_text("test address forwarding")
  end

  scenario "email forwarding" do
    @mail = create(:mail_postal_mail, inbox: @user.inbox)
    visit mails_path
    click_link('Some notes')
    expect(page).to have_button('Email Forward')
    click_button('Email Forward')
    expect(page).to have_text("Forward as Email")

    # invalid email address
    fill_in 'email_list', with: 'test@local.com, test'
    click_button('Forward')
    expect(page).to have_text("The email 'test' is invalid.")
    # valid email address
    click_link('Some notes')
    click_button('Email Forward')
    fill_in 'email_list', with: 'test@local.com, test2@local.com'
    click_button('Forward')
    expect(page).to have_text("Mail forwarded to 'test@local.com, test2@local.com'.")
  end

  scenario "delete mail" do
    @mail = create(:mail_postal_mail, inbox: @user.inbox)
    visit mails_path
    click_link('Some notes')
    expect(page).to have_button('Delete')
    click_button('Delete')
    expect(page).to have_text("Your mail has been deleted.")
    expect(page).not_to have_css('.mail-inbox__main__list__item__notes')
  end

  scenario "filters display correct list" do
    @mail = create(:mail_postal_mail, inbox: @user.inbox)
    @opened = create(:mail_postal_mail, inbox: @user.inbox, notes:"opened mail", state:'opened')
    @archived_mail = create(:mail_postal_mail, inbox: @user.inbox, notes:"archived mail", archived_at: Time.now)
    @unpaid_mail = create(:mail_postal_mail, inbox: @user.inbox, notes:"unpaid mail", bill_attributes: {
      due_date: '2020-10-02 12:00:00',
      description: 'Water & Sewage bill from Tokyo Water',
      subtotal_amount: 5995,
      total_amount: 6475,
      processing_fee_amount: 480,
      user_id: @user.id
      })
    @paid_mail = create(:mail_postal_mail, inbox: @user.inbox, notes:"paid mail", bill_attributes: {
    due_date: '2020-10-02 12:00:00',
    description: 'Water & Sewage bill from Tokyo Water',
    subtotal_amount: 5995,
    total_amount: 6475,
    processing_fee_amount: 480,
    user_id: @user.id
    })
    @paid_mail.bill.update!(state:'paid')

    # All filter
    visit mails_path
    expect(page).to have_css('.mail-inbox__main__list__item__notes', count: 4)

    # Unopend filter
    click_link 'Unopened'
    expect(page).to have_css('.mail-inbox__main__list__item__notes', count: 3)
    expect(page).not_to have_text('opened mail')

    # Archvied filter
    click_link('Archived')
    expect(page).to have_css('.mail-inbox__main__list__item__notes', count: 1)
    expect(page).to have_text('archived mail')

    # Unpaid filter
    click_link('Unpaid')
    expect(page).to have_css('.mail-inbox__main__list__item__notes', count: 1)
    expect(page).to have_text('unpaid mail')

    # Paid filter
    click_link('Paid')
    expect(page).to have_css('.mail-inbox__main__list__item__notes', count: 1)
    expect(page).to have_text('paid mail')
  end

  scenario "Pay an unpaid bill" do
    @unpaid_mail = create(:mail_postal_mail, inbox: @user.inbox, notes:"unpaid mail", bill_attributes: {
      due_date: '2020-10-02 12:00:00',
      description: 'Water & Sewage bill from Tokyo Water',
      subtotal_amount: 5995,
      total_amount: 6475,
      processing_fee_amount: 480,
      user_id: @user.id
      })
    visit mails_path
    click_link('unpaid mail')
    expect(page).to have_text("This mail contains an unpaid bill for ¥6,475 due on 2020-10-02")
    click_button("Pay Bill")
    expect(page).to have_text("Pay A Bill")
    expect(page).to have_text("¥6,475")
    expect(page).to have_text("Water & Sewage bill from Tokyo Water ¥5995 + ¥480 processing fee.")
    expect(page).to have_text("ending **** **** **** 4242")
    expect(page).to have_link("Change")
    expect(page).to have_button("Confirm Payment")

    click_button("Confirm Payment")

    expect(page).to have_text("Thanks! Your payment has been received!")
    click_link('unpaid mail')
    expect(page).not_to have_text("This mail contains an unpaid bill for ¥6,475 due on 2020-10-02")
    expect(page).to have_text("This bill has been paid. No further action required.")

    # unpaid folder should also be empty
    visit mails_path
    click_link('Unpaid')
    expect(page).not_to have_css('.mail-inbox__main__list__item__notes')
  end

  scenario "edit mail notes" do
    @mail = create(:mail_postal_mail, inbox: @user.inbox)
    visit mails_path
    click_link("Some notes")
    click_button("Edit Notes")
    expect(page).to have_field('mail_postal_mail_notes',with: "Some notes")
    fill_in 'mail_postal_mail_notes', with: "Some notes updated!"
    click_button("Save Notes")
    expect(page).to have_text('Notes has been updated')
    expect(page).to have_text('Some notes updated!')
    click_link('Some notes updated!')
    click_button("Edit Notes")
    fill_in 'mail_postal_mail_notes', with: ""
    click_button("Save Notes")
    expect(page).to have_text('Notes cannot be empty.')
    expect(page).to have_text('Some notes updated!')
  end

  scenario "create rename and delete a folder" do
    visit mails_path

    # create new folder
    Capybara.ignore_hidden_elements = false
    click_button ("Create Folder")
    fill_in 'mail_folder_name', with: 'test folder'
    click_button"Create Folder"
    expect(page).to have_text('Folder created')
    expect(page).to have_text("test folder")

    folder = Mail::Folder.find_by(name:"test folder")

    # rename folder
    click_link "Edit folder #{folder.name}"
    fill_in 'mail_folder_name', with: 'test folder updated'
    click_button"Rename"
    expect(page).to have_text('Folder updated')
    expect(page).to have_text("test folder updated")

    # delete folder
    # failing: capybara not working with Turbo response
    # click_link "Edit folder #{folder.name}"
    # click_link "Delete Folder"
    # expect(page).to have_text('Folder deleted')
    # expect(page).not_to have_text("test folder updated")
end

  scenario "move mail in/out of a folder" do
    # create mail and folder
    @mail = create(:mail_postal_mail, inbox: @user.inbox)
    visit mails_path
    click_button "Create Folder"
    fill_in 'mail_folder_name', with: 'important'
    click_button"Create Folder"

    # move mail into folder
    expect(page).to have_text("Some notes")
    click_link('Some notes')
    click_button('Move')
    fill_in 'Search your folders...', with: 'important'
    click_link("important")
    expect(page).to have_text("Your mail has been moved to important")
    expect(page).not_to have_text("Some notes")
    click_link("important (1)")
    expect(page).to have_text("Some notes")

    # move mail out of folder
    click_link('Some notes')
    click_button('Move')
    expect(page).to have_button"important"
    click_button("important")
    click_link("Inbox")
    expect(page).to have_text"Some notes"
    click_link("important (0)")
    expect(page).not_to have_text"Some notes"
  end

  scenario "create rename and delete a tag" do
    visit mails_path

    # create new tag
    Capybara.ignore_hidden_elements = false
    click_button ("Create Tag")
    fill_in 'mail_tag_name', with: 'test tag'
    click_button"Create Tag"
    expect(page).to have_text('Tag created')
    expect(page).to have_text("test tag")

    tag = Mail::Tag.find_by(name:"test tag")

    # rename tag
    click_link "Edit tag #{tag.name}"
    fill_in 'mail_tag_name', with: 'test tag updated'
    click_button"Rename"
    expect(page).to have_text('Tag updated')
    expect(page).to have_text("test tag updated")
  end

  scenario "tag/un-tag a mail" do
    # create mail and folder
    @mail = create(:mail_postal_mail, inbox: @user.inbox)
    visit mails_path
    click_button "Create Tag"
    fill_in 'mail_tag_name', with: 'important'
    click_button"Create Tag"

    # capybara not working with turbo stream response
    # # tag a mail
    # expect(page).to have_text("Some notes")
    # click_link('Some notes')
    # click_button('Tag')
    # fill_in 'Search your tags...', with: 'important'
    # click_link("important")
    # expect(page).to have_text("Your mail has been tagged as important")
    # expect(page).not_to have_text("Some notes")
    # click_link("important")
    # expect(page).to have_text("Some notes")

    # # untag a mail
    # click_link('Some notes')
    # click_button('Tag')
    # expect(page).to have_button"important ✖️ "
    # click_button("important ✖️ ")
    # click_link("Inbox")
    # expect(page).to have_text"Some notes"
    # click_link("important")
    # expect(page).not_to have_text"Some notes"
  end
end