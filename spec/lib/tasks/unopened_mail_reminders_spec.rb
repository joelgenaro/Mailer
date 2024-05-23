require 'rails_helper'
require 'rake'
describe "rake unopened_mail_reminders:three_days", type: :task do
  before do
    @mail = create(:mail_postal_mail)
    @user = @mail.user
    @user.update(current_sign_in_at:3.days.ago)
  end
  
  context "user have one unopened mail" do
    it "send a three days reminder" do
      expect(@user.remindable_postal_mails.count).to eq(1)
      Rake::Task['unopened_mail_reminders:three_days'].invoke
      expect(@user.reminders.last.kind).to eq('unopened_mail_three_days')
    end
  end

  context "user have an unopened and deleted mail" do
    it "does not send a three days reminder" do
      @mail.update!(deleted_at:DateTime.now)
      expect(@user.remindable_postal_mails.count).to eq(0)
      Rake::Task['unopened_mail_reminders:three_days'].invoke
      expect(@user.reminders.last).to eq(nil)
    end
  end
end

describe "rake unopened_mail_reminders:ten_days", type: :task do
  before do
    @mail = create(:mail_postal_mail)
    @user = @mail.user
    @user.update(current_sign_in_at:10.days.ago)
  end

  context "user have one unopened mail" do
    it "sends a ten days reminder" do
      expect(@user.remindable_postal_mails.count).to eq(1)
      Rake::Task['unopened_mail_reminders:ten_days'].invoke
      expect(@user.reminders.last.kind).to eq('unopened_mail_ten_days')
    end
  end
  context "user have an unopened and deleted mails" do
    it "does not send a ten days reminder" do
      @mail.update!(deleted_at:DateTime.now)
      expect(@user.remindable_postal_mails.count).to eq(0)
      Rake::Task['unopened_mail_reminders:ten_days'].invoke
      expect(@user.reminders.last).to eq(nil)
    end
  end
end