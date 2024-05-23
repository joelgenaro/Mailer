# == Schema Information
#
# Table name: postal_mails
#
#  id                    :bigint           not null, primary key
#  archived_at           :datetime
#  deleted_at            :datetime
#  notes                 :string
#  received_on           :date
#  shred_requested_at    :datetime
#  shredded_at           :datetime
#  state                 :string           default("unopened")
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  archived_by_id        :bigint
#  deleted_by_id         :bigint
#  inbox_id              :bigint
#  mail_recipient_id     :bigint
#  shred_requested_by_id :bigint
#  shredded_by_id        :bigint
#  user_id               :bigint
#
# Indexes
#
#  index_postal_mails_on_archived_by_id         (archived_by_id)
#  index_postal_mails_on_deleted_by_id          (deleted_by_id)
#  index_postal_mails_on_inbox_id               (inbox_id)
#  index_postal_mails_on_mail_recipient_id      (mail_recipient_id)
#  index_postal_mails_on_shred_requested_by_id  (shred_requested_by_id)
#  index_postal_mails_on_shredded_by_id         (shredded_by_id)
#  index_postal_mails_on_user_id                (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (mail_recipient_id => mail_recipients.id)
#  fk_rails_...  (user_id => users.id)
#

require 'rails_helper'

RSpec.describe Mail::PostalMail, type: :model do
  
  context 'Relationships' do 
    it 'mail_recipient' do 
      should belong_to(:mail_recipient)
      should_not belong_to(:mail_recipient).dependent(:destroy)
    end

    it 'credit_transations' do 
      should have_many(:credit_transactions)
    end
  end

  context 'Callbacks' do 
    it 'before_validation_set_inbox_and_user_from_recipient' do 
      mail_recipient = create(:mail_recipient)
      subject = build(:mail_postal_mail)
      subject.mail_recipient = mail_recipient
      expect(subject.inbox).to be_nil
      expect(subject.user).to be_nil
      subject.save
      expect(subject.inbox).to eq(mail_recipient.inbox)
      expect(subject.user).to eq(mail_recipient.inbox.user)
    end
  end

  context 'Methods' do 
    it 'credit_spend_content_scan!' do 
      subject = create(:mail_postal_mail)
      expect(subject.credit_transactions.count).to eq(0)
      expect(subject.credit_spent_content_scan?).to eq(false)
      expect(subject.credit_spent_translation_summary?).to eq(false)

      subject.credit_spend_content_scan!
      expect(subject.credit_transactions.count).to eq(1)
      expect(subject.credit_spent_content_scan?).to eq(true)
      expect(subject.credit_spent_translation_summary?).to eq(false)
      expect(subject.credit_transactions.last).to have_attributes(
        inbox_id: subject.inbox_id,
        credit_type: 'mail_content_scan',
        reason: 'user_request',
        amount: -1, 
        object_id: subject.id,
        object_type: subject.class.name
      )
    end

    it 'credit_spent_content_scan?' do 
      subject = create(:mail_postal_mail)

      # Correct reason/type
      expect(subject.credit_spent_content_scan?).to eq(false)
      create(:mail_credit_transaction, :credit_type__mail_translation_summary__spend__user_request, inbox: subject.inbox, object: subject)
      expect(subject.credit_spent_content_scan?).to eq(false)
      create(:mail_credit_transaction, :credit_type__mail_content_scan__spend__user_request, inbox: subject.inbox, object: subject)    
      expect(subject.credit_spent_content_scan?).to eq(true)

      # Must be negative amount
      subject = create(:mail_postal_mail)
      expect(subject.credit_spent_content_scan?).to eq(false)
      transaction = create(:mail_credit_transaction, :credit_type__mail_content_scan__spend__user_request, inbox: subject.inbox, object: subject, amount: 0)
      expect(subject.credit_spent_content_scan?).to eq(false)
      transaction.destroy
      create(:mail_credit_transaction, :credit_type__mail_content_scan__spend__user_request, inbox: subject.inbox, object: subject, amount: -1)
      expect(subject.credit_spent_content_scan?).to eq(true)
    end

    it 'credit_spent_translation_summary?' do 
      subject = create(:mail_postal_mail)

      # Correct reason/type
      expect(subject.credit_spent_translation_summary?).to eq(false)
      create(:mail_credit_transaction, :credit_type__mail_content_scan__spend__user_request, inbox: subject.inbox, object: subject)
      expect(subject.credit_spent_translation_summary?).to eq(false)
      create(:mail_credit_transaction, :credit_type__mail_translation_summary__spend__user_request, inbox: subject.inbox, object: subject)
      expect(subject.credit_spent_translation_summary?).to eq(true)

      # Must be negative amount
      subject = create(:mail_postal_mail)
      expect(subject.credit_spent_translation_summary?).to eq(false)
      transaction = create(:mail_credit_transaction, :credit_type__mail_translation_summary__spend__user_request, inbox: subject.inbox, object: subject, amount: 0)
      expect(subject.credit_spent_translation_summary?).to eq(false)
      transaction.destroy
      create(:mail_credit_transaction, :credit_type__mail_translation_summary__spend__user_request, inbox: subject.inbox, object: subject, amount: -1)
      expect(subject.credit_spent_translation_summary?).to eq(true)
    end
  end
end
