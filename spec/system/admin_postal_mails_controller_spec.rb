require 'rails_helper'

RSpec.describe Admin::PostalMailsController, type: :controller do
  include ControllerHelper
  include AuthHelper

  let(:stripe_helper) { StripeMock.create_test_helper }

  before do 
    http_login
    StripeMock.start
    DatabaseCleaner.start
    @user = create(:user, :with_profile, :with_payment_method)
    @subscription = create(:subscription, :with_plan_mail, user: @user)
    @mail = create(:mail_postal_mail, inbox: @user.inbox)
    @admin_user = create(:admin_user)
    sign_in @admin_user
  end

  after do
    StripeMock.stop
    DatabaseCleaner.clean
    # puts "mails count: #{Mail::PostalMail.count}"
  end

  context "when notify shred is on" do
    it "send shredded notification mail" do
      expect {
        put :mark_as_shredded, params: {id: @mail.id}
      }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
      .with('Mail::PostalMailMailer', 'shredded_email', "deliver_now", {:args=>[Integer]})
    end
  end

  context "when notify shred is off" do
    it "does not send shredded notification mail" do
      Mail::Inbox.find(@mail.inbox.id).update(notify_shred:false)
      expect {
        put :mark_as_shredded, params: {id: @mail.id}
      }.not_to have_enqueued_job(ActionMailer::MailDeliveryJob)
      .with('Mail::PostalMailMailer', 'shredded_email', "deliver_now", {:args=>[1]})
    end
  end
end