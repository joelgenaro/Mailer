require 'rails_helper'

RSpec.describe Frontend::Mails::PostalMailController, type: :controller do
  include ControllerHelper
  include AuthHelper

  let(:stripe_helper) { StripeMock.create_test_helper }

  before do 
    http_login
    StripeMock.start

    @user = create(:user, :with_profile, :with_payment_method)
    @subscription = create(:subscription, :with_plan_mail, user: @user)
    @mail = create(:mail_postal_mail, inbox: @user.inbox)
    sign_in @user
  end

  after do
    StripeMock.stop
  end

  context "perform archive, unarchive, delete, shred request correctly" do
    it "archives" do
        patch :archive, params: {id: @mail.id}
        expect(Mail::PostalMail.find(@mail.id).archived_at.to_s).to eq(Time.now.utc.to_s)
        expect(Mail::PostalMail.find(@mail.id).archived_by.id).to eq(@user.id)
        expect(subject.request.flash.notice).to eq('Your mail has been archived.')
    end
    it "unarchives" do
        patch :unarchive, params: {id: @mail.id}
        expect(Mail::PostalMail.find(@mail.id).archived_at).to be_nil
        expect(Mail::PostalMail.find(@mail.id).archived_by).to be_nil
        expect(subject.request.flash.notice).to eq('Your mail has been unarchived.')
    end
    it "request shredding" do
        patch :shred, params: {id: @mail.id}
        expect(Mail::PostalMail.find(@mail.id).shred_requested_at.to_s).to eq(Time.now.utc.to_s)
        expect(Mail::PostalMail.find(@mail.id).shred_requested_by.id).to eq(@user.id)
        expect(subject.request.flash.notice).to eq('Your mail is requested to be shredded. Your mail will be shredded within 24 hours.')
    end
    it "delete" do
        patch :delete, params: {id: @mail.id}
        expect(Mail::PostalMail.find(@mail.id).deleted_at.to_s).to eq(Time.now.utc.to_s)
        expect(Mail::PostalMail.find(@mail.id).deleted_by.id).to eq(@user.id)
        expect(subject.request.flash.notice).to eq('Your mail has been deleted.')
    end
    it "render forwarding form" do
        get :forward_form, params: {id: @mail.id}
        expect(response).to render_template(:mail_forward_form)
    end
    it "request forwarding" do
        patch :forward_request, params: {id: @mail.id, address: "Test address for forwarding"}, format: :turbo_stream
        expect(Mail::PostalMail.find(@mail.id).forward_request).not_to be_nil
        expect(Mail::PostalMail.find(@mail.id).forward_request.address).to eq("Test address for forwarding")
        expect(response).to render_template("frontend/mails/mail_item","frontend/shared/_alerts")
    end
  end
end