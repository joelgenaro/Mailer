# == Schema Information
#
# Table name: mail_credit_transactions
#
#  id          :bigint           not null, primary key
#  amount      :integer
#  balance     :integer
#  credit_type :string
#  expires_at  :datetime
#  object_type :string
#  reason      :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  inbox_id    :bigint
#  object_id   :bigint
#
# Indexes
#
#  index_mail_credit_transactions_on_inbox_id                   (inbox_id)
#  index_mail_credit_transactions_on_object_type_and_object_id  (object_type,object_id)
#
# Foreign Keys
#
#  fk_rails_...  (inbox_id => inboxes.id)
#

require 'rails_helper'

RSpec.describe Mail::CreditTransaction, type: :model do
  context "Validations" do 
    subject { build(:mail_credit_transaction) }

    it 'inbox' do 
      # Required
      should belong_to(:inbox)
      should_not allow_value(nil).for(:inbox)
      should_not belong_to(:inbox).dependent(:destroy)
    end

    it 'object' do 
      # Required - TODO
      # should belong_to(:object)
      # should_not allow_value(nil).for (:object)
      # should_not belong_to(:object).dependent(:destroy)
    end

    it 'credit_type' do 
      should_not allow_value(nil).for (:credit_type) # Required 
      # Enum
      ['mail_content_scan', 'mail_translation_summary'].each do |value| 
        should allow_value(value).for(:credit_type)
      end
      should_not allow_value('bad').for(:credit_type)
    end

    it 'amount' do 
      should_not allow_value(nil).for(:amount) # Required 
      [-10, -1, 0, 1, 10].each do |value| # Numeric
        should allow_value(value).for(:amount)
      end
    end

    it 'reason' do
      should_not allow_value(nil).for(:reason) # Required 
      # Enum
      ['subscription', 'additional_purchase', 'user_request', 'expiration'].each do |value|
        should allow_value(value).for(:reason)
      end
    end

    it 'balance' do 
      # Required on update
      should allow_value(nil).for(:balance).on(:create)
      should_not allow_value(nil).for(:balance).on(:update)
      [-10, -1, 0, 1, 10].each do |value| # Numeric
        should allow_value(value).for(:balance)
      end
    end

    it "validate_reason_and_amount_for_credit_type" do 
      subject = Mail::CreditTransaction.new
      # Ingores if no credit_type, amount or reason 
      expect(subject.credit_type).to be_nil
      expect(subject.amount).to be_nil
      expect(subject.reason).to be_nil
      expect(subject.valid?).to eq(false)
      expect(subject.errors.full_messages).to_not include('Reason is not found for credit type')

      # Handles if bad reason for credit type
      subject.credit_type = 'mail_content_scan'
      subject.reason = 'bad'
      subject.amount = 10
      expect(subject.valid?).to eq(false)
      expect(subject.errors.full_messages).to include('Reason is not found for credit type')

      # Ensures amount is negative or positive based on reason type ('income' or 'spend')
      subject.credit_type = 'mail_content_scan'
      subject.reason = 'subscription'
      subject.amount = -1
      expect(subject.valid?).to eq(false)
      expect(subject.errors.full_messages).to include('Amount is invalid for reason')
      subject.credit_type = 'mail_content_scan'
      subject.reason = 'user_request'
      subject.amount = 1
      expect(subject.valid?).to eq(false)
      expect(subject.errors.full_messages).to include('Amount is invalid for reason')

      # All good! 
      subject.credit_type = 'mail_content_scan'
      subject.reason = 'subscription'
      subject.amount = 1
      expect(subject.valid?).to eq(false)
      expect(subject.errors.full_messages).to_not include('Reason is not found for credit type')
      expect(subject.errors.full_messages).to_not include('Amount is invalid for reason')
      subject.credit_type = 'mail_content_scan'
      subject.reason = 'user_request'
      subject.amount = -1
      expect(subject.valid?).to eq(false)
      expect(subject.errors.full_messages).to_not include('Reason is not found for credit type')
      expect(subject.errors.full_messages).to_not include('Amount is invalid for reason')
    end

    it 'validate_no_updates_after_create' do 
      subject = create(:mail_credit_transaction, :credit_type__mail_content_scan__income__additional_purchase)  
      expect(subject.valid?).to eq(true)

      subject.inbox = create(:mail_inbox)
      expect(subject.valid?).to eq(false)
      expect(subject.errors.full_messages.count).to eq(1)
      expect(subject.errors.full_messages).to include('Inbox can not be changed')

      subject.credit_type = :mail_translation_summary
      expect(subject.valid?).to eq(false)
      expect(subject.errors.full_messages.count).to eq(2)
      expect(subject.errors.full_messages).to include('Credit type can not be changed')

      subject.amount = 999
      expect(subject.valid?).to eq(false)
      expect(subject.errors.full_messages.count).to eq(3)
      expect(subject.errors.full_messages).to include('Amount can not be changed')

      subject.reason = :subscription
      expect(subject.valid?).to eq(false)
      expect(subject.errors.full_messages.count).to eq(4)
      expect(subject.errors.full_messages).to include('Reason can not be changed')

      subject.balance = 9999999
      expect(subject.valid?).to eq(false)
      expect(subject.errors.full_messages.count).to eq(5)
      expect(subject.errors.full_messages).to include('Balance can not be changed')

      subject.expires_at = Time.now
      expect(subject.valid?).to eq(false)
      expect(subject.errors.full_messages.count).to eq(6)
      expect(subject.errors.full_messages).to include('Expires at can not be changed')
    end

    it 'validate_expires_at_presence_based_on_reason' do 
      subject = build(:mail_credit_transaction, :credit_type__mail_content_scan__income__subscription, expires_at: nil)

      # Do both credit types
      [:mail_content_scan, :mail_translation_summary].each do |credit_type|
        subject.credit_type = credit_type
        # Do all 'income' reasons
        [:subscription, :additional_purchase].each do |reason|
          subject.reason = reason
          expect(subject.expires_at).to be_nil
          expect(subject.valid?).to eq(false)
          expect(subject.errors.full_messages).to include('Expires at is required for reason')
        end
      end

      # Not required for 'spend' reasons
      [:mail_content_scan, :mail_translation_summary].each do |credit_type|
        subject.credit_type = credit_type
        subject.amount = -1
        # Do all 'income' reasons
        [:user_request, :expiration].each do |reason|
          subject.reason = reason
          expect(subject.expires_at).to be_nil
          expect(subject.valid?).to eq(true)
          expect(subject.errors.full_messages).to_not include('Expires at is required for reason')
        end
      end
    end
  end

  context 'Callbacks' do 
    it 'before_create_calculate_and_set_balance' do 
      mail_inbox = create(:mail_inbox)

      # Handles if first one
      expect(mail_inbox.credit_transactions.count).to eq(0)
      subject = build(:mail_credit_transaction, :credit_type__mail_content_scan__income__subscription, inbox: mail_inbox)      
      expect(subject.balance).to be_nil
      subject.save
      expect(subject.balance).to eq(15)

      # Handles if previous ones
      mail_inbox.credit_transactions.reload
      expect(mail_inbox.credit_transactions.count).to eq(1)
      subject = create(:mail_credit_transaction, :credit_type__mail_content_scan__income__additional_purchase, inbox: mail_inbox)      
      expect(subject.balance).to eq(18)
      subject = create(:mail_credit_transaction, :credit_type__mail_content_scan__spend__expiration, inbox: mail_inbox)      
      expect(subject.balance).to eq(13)
      mail_inbox.credit_transactions.reload
      expect(mail_inbox.credit_transactions.count).to eq(3)

      # Handles if different credit_type
      subject = build(:mail_credit_transaction, :credit_type__mail_translation_summary__spend__user_request, inbox: mail_inbox)      
      expect(subject.balance).to be_nil
      subject.save
      expect(subject.balance).to eq(-1)
    end
  end

  context 'Balance' do 
    it 'self.balance_for_inbox' do 
      mail_inbox = create(:mail_inbox)
      expect(mail_inbox.credit_transactions.count).to eq(0)

      # Handles if none, will be 0
      expect(Mail::CreditTransaction.balance_for_inbox(mail_inbox, :mail_content_scan)).to eq(0)

      # First 
      create(:mail_credit_transaction, :credit_type__mail_content_scan__income__subscription, inbox: mail_inbox)      
      expect(Mail::CreditTransaction.balance_for_inbox(mail_inbox, :mail_content_scan)).to eq(15)

      # Another one
      create(:mail_credit_transaction, :credit_type__mail_content_scan__income__additional_purchase, inbox: mail_inbox)      
      expect(Mail::CreditTransaction.balance_for_inbox(mail_inbox, :mail_content_scan)).to eq(18)

      # Handles negative balance
      create(:mail_credit_transaction, :credit_type__mail_content_scan__spend__expiration, inbox: mail_inbox, amount: -20)
      expect(Mail::CreditTransaction.balance_for_inbox(mail_inbox, :mail_content_scan)).to eq(-2)

      # Handles different credit type
      expect(Mail::CreditTransaction.balance_for_inbox(mail_inbox, :mail_translation_summary)).to eq(0)
      create(:mail_credit_transaction, :credit_type__mail_translation_summary__income__additional_purchase, inbox: mail_inbox)
      expect(Mail::CreditTransaction.balance_for_inbox(mail_inbox, :mail_translation_summary)).to eq(3)
      expect(Mail::CreditTransaction.balance_for_inbox(mail_inbox, :mail_content_scan)).to eq(-2) # Stays same
    end
  end

  context 'Expiration' do 
    context 'self.handle_expirations_for_inbox!' do 
      it 'no income credit transactions inbetween' do 
        Timecop.freeze('2021-02-01') do
          # Here we'll have no other 'income' credit transaction
          # inbetween the 1st's creation and expiration
          #
          # created_at : reason : amount : expires_at: balance
          # 2/1 : expiration : -3 : na : 0
          # 1/9 : user_request : -1 : na : 3
          # 1/3 : user_request : -1 : na : 4
          # 1/1 : subscription : 5 : 2/1 : 5

          inbox = create(:mail_inbox)
          subject = create(:mail_credit_transaction, :credit_type__mail_content_scan__income__subscription, inbox: inbox, amount: 5, expires_at: Time.new(2021,2,1), created_at: Time.new(2021,1,1))
          create(:mail_credit_transaction, :credit_type__mail_content_scan__spend__user_request, inbox: inbox, amount: -1, created_at: Time.new(2021,1,3))
          create(:mail_credit_transaction, :credit_type__mail_content_scan__spend__user_request, inbox: inbox, amount: -1, created_at: Time.new(2021,1,9))
          
          expect(Mail::CreditTransaction.balance_for_inbox(inbox, :mail_content_scan)).to eq(3)
          expect(inbox.credit_transactions.with_credit_type(:mail_content_scan).last.reason).to_not eq('expiration')

          inbox.credits_balance_last_processed_at = Time.new(2021,2,1)
          Mail::CreditTransaction.handle_expirations_for_inbox!(inbox)

          expect(Mail::CreditTransaction.balance_for_inbox(inbox, :mail_content_scan)).to eq(0)
          last_credit_transaction = inbox.credit_transactions.with_credit_type(:mail_content_scan).last
          expect(last_credit_transaction.reason).to eq('expiration')
          expect(last_credit_transaction.amount).to eq(-3)
          expect(last_credit_transaction.object).to eq(subject)
        end
      end

      it 'income credit transactions inbetween' do 
        Timecop.freeze('2021-02-01') do
          # Here, we'll have a 2nd 'income' credit transaction created 
          # inbetween the 1st's creation and expiration. We'll also ensure
          # it consider's previous 'income' transactions credits that were used
          #
          # created_at : reason : amount : expires_at: balance
          # 2/1 : expiration : -3 : na : 4
          # 1/20: user_request : -1 : na : 6
          # 1/15: additional_purchase : 4 : 2/15 : 7
          # 1/9 : user_request : -1 : na : 3
          # 1/3 : user_request : -1 : na : 4
          # 1/1 : subscription : 5 : 2/1 : 5

          inbox = create(:mail_inbox)
          subject_1 = create(:mail_credit_transaction, :credit_type__mail_translation_summary__income__subscription, inbox: inbox, amount: 5, expires_at: Time.new(2021,2,1), created_at: Time.new(2021,1,1))
          create(:mail_credit_transaction, :credit_type__mail_translation_summary__spend__user_request, inbox: inbox, amount: -1, created_at: Time.new(2021,1,3))
          create(:mail_credit_transaction, :credit_type__mail_translation_summary__spend__user_request, inbox: inbox, amount: -1, created_at: Time.new(2021,1,9))
          subject_2 = create(:mail_credit_transaction, :credit_type__mail_translation_summary__income__additional_purchase, inbox: inbox, amount: 4, expires_at: Time.new(2021,2,15), created_at: Time.new(2021,1,15))
          create(:mail_credit_transaction, :credit_type__mail_translation_summary__spend__user_request, inbox: inbox, amount: -1, created_at: Time.new(2021,1,20))

          expect(Mail::CreditTransaction.balance_for_inbox(inbox, :mail_translation_summary)).to eq(6)
          expect(inbox.credit_transactions.with_credit_type(:mail_translation_summary).last.reason).to_not eq('expiration')
          
          inbox.credits_balance_last_processed_at = Time.new(2021,2,1)
          Mail::CreditTransaction.handle_expirations_for_inbox!(inbox)
          expect(Mail::CreditTransaction.balance_for_inbox(inbox, :mail_translation_summary)).to eq(4)
          last_credit_transaction = inbox.credit_transactions.with_credit_type(:mail_translation_summary).last
          expect(last_credit_transaction.reason).to eq('expiration')
          expect(last_credit_transaction.amount).to eq(-2)
          expect(last_credit_transaction.object).to eq(subject_1)

          # Now if we go forward to 2/15 when the 2nd 'income' credit transaction
          # expires, it should expire in full as not used. Note the 
          # 'user_request' 'spend' credit transactions on the 1/20 which will be covered
          # by the 1st 'income' credit transaction, so the 2nd doesn't consider this.
          # Things will look like this:
          #
          # created_at : reason : amount : expires_at: balance
          # 2/15 : expiration : -4 : na : 0
          # 2/1 : expiration : -3 : na : 4
          # 1/20: user_request : -1 : na : 6
          # 1/15: additional_purchase : 4 : 2/15 : 7
          # 1/9 : user_request : -1 : na : 3
          # 1/3 : user_request : -1 : na : 4
          # 1/1 : subscription : 5 : 2/1 : 5
          Timecop.travel('2021-02-15')
          inbox.credits_balance_last_processed_at = Time.new(2021,2,15)
          Mail::CreditTransaction.handle_expirations_for_inbox!(inbox)
          expect(Mail::CreditTransaction.balance_for_inbox(inbox, :mail_translation_summary)).to eq(0)
          last_credit_transaction = inbox.credit_transactions.with_credit_type(:mail_translation_summary).last
          expect(last_credit_transaction.reason).to eq('expiration')
          expect(last_credit_transaction.amount).to eq(-4)
          expect(last_credit_transaction.object).to eq(subject_2)

          # Deleting the last expiration (to do over), lets say the
          # we had another 'spend' creditation transaction after the 
          # 1st 'income' credit transaction's expiration. Will look like this:
          #
          # created_at : reason : amount : expires_at: balance
          # 2/15 : expiration : -3 : na : 0
          # 2/10: user_request : -1 : na : 3
          # 2/1 : expiration : -3 : na : 4
          # 1/20: user_request : -1 : na : 6
          # 1/15: additional_purchase : 4 : 2/15 : 7
          # 1/9 : user_request : -1 : na : 3
          # 1/3 : user_request : -1 : na : 4
          # 1/1 : subscription : 5 : 2/1 : 5
          last_credit_transaction.destroy
          create(:mail_credit_transaction, :credit_type__mail_translation_summary__spend__user_request, inbox: inbox, amount: -1, created_at: Time.new(2021,2,10))
          expect(Mail::CreditTransaction.balance_for_inbox(inbox, :mail_translation_summary)).to eq(3)

          inbox.credits_balance_last_processed_at = Time.new(2021,2,15)
          Mail::CreditTransaction.handle_expirations_for_inbox!(inbox)
          expect(Mail::CreditTransaction.balance_for_inbox(inbox, :mail_translation_summary)).to eq(0)
          last_credit_transaction = inbox.credit_transactions.with_credit_type(:mail_translation_summary).last
          expect(last_credit_transaction.reason).to eq('expiration')
          expect(last_credit_transaction.amount).to eq(-3)
          expect(last_credit_transaction.object).to eq(subject_2)
        end
      end

      it 'used in full and chronological order' do 
        Timecop.freeze('2021-02-15') do
          # Here we'll test two things: 
          # - If a 'income' credit transaction is used in full, it's expiration will have a '0' amount
          # - Expiring 'income' credit transactions are ordered chronologically, so the oldest will be considered first
          #
          # This *shouldn't* but could happen if we were late processing expirations
          # (like a task is broken for a day or something).
          #
          # What things will look is: 
          # created_at : reason : amount : expires_at: balance
          # 2/15 : expiration : -3 : na : 0
          # 2/1 : expiration : 0 : na : 3
          # 1/20: user_request : -1 : na : 3
          # 1/15: additional_purchase : 4 : 2/15 : 4
          # 1/9 : user_request : -4 : na : 0
          # 1/3 : user_request : -1 : na : 4
          # 1/1 : subscription : 5 : 2/1 : 5

          inbox = create(:mail_inbox)
          subject_1 = create(:mail_credit_transaction, :credit_type__mail_translation_summary__income__subscription, inbox: inbox, amount: 5, expires_at: Time.new(2021,2,1), created_at: Time.new(2021,1,1))
          create(:mail_credit_transaction, :credit_type__mail_translation_summary__spend__user_request, inbox: inbox, amount: -1, created_at: Time.new(2021,1,3))
          create(:mail_credit_transaction, :credit_type__mail_translation_summary__spend__user_request, inbox: inbox, amount: -4, created_at: Time.new(2021,1,9))
          subject_2 = create(:mail_credit_transaction, :credit_type__mail_translation_summary__income__additional_purchase, inbox: inbox, amount: 4, expires_at: Time.new(2021,2,15), created_at: Time.new(2021,1,15))
          create(:mail_credit_transaction, :credit_type__mail_translation_summary__spend__user_request, inbox: inbox, amount: -1, created_at: Time.new(2021,1,20))

          expect(Mail::CreditTransaction.balance_for_inbox(inbox, :mail_translation_summary)).to eq(3) 
          expect(inbox.credit_transactions.with_credit_type(:mail_translation_summary).where(reason: 'expiration').count).to eq(0)

          inbox.credits_balance_last_processed_at = Time.new(2021,2,1)
          Mail::CreditTransaction.handle_expirations_for_inbox!(inbox)
          expect(inbox.credit_transactions.with_credit_type(:mail_translation_summary).where(reason: 'expiration').count).to eq(2)
          last_2_expiration_credit_transactions = inbox.credit_transactions.with_credit_type(:mail_translation_summary).last(2)

          first_expiration_credit_transaction = last_2_expiration_credit_transactions.first
          expect(first_expiration_credit_transaction.reason).to eq('expiration')
          expect(first_expiration_credit_transaction.amount).to eq(0)
          expect(first_expiration_credit_transaction.object).to eq(subject_1)

          second_expiration_credit_transaction = last_2_expiration_credit_transactions.second
          expect(second_expiration_credit_transaction.reason).to eq('expiration')
          expect(second_expiration_credit_transaction.amount).to eq(-3)
          expect(second_expiration_credit_transaction.object).to eq(subject_2)
        end
      end
    end
  end

  context 'Allocation' do 
    it 'self.create_monthly_allocations_for_plan!' do 
      mail_inbox = create(:mail_inbox)
      expect(mail_inbox.credit_transactions.count).to eq(0)

      # If does nothing if no scans or summaries (eg mail_starter plan)
      Mail::CreditTransaction.create_monthly_allocations_for_plan!(
        inbox: mail_inbox,
        plan: :mail_starter
      )
      mail_inbox.credit_transactions.reload
      expect(mail_inbox.credit_transactions.count).to eq(0)

      # Creates both Mail Content Scans and Mail Translation Summaries
      Mail::CreditTransaction.create_monthly_allocations_for_plan!(
        inbox: mail_inbox,
        plan: :mail_standard
      )
      mail_inbox.credit_transactions.reload
      expect(mail_inbox.credit_transactions.count).to eq(2)

      credit_transaction_mail_content_scan = mail_inbox.credit_transactions.with_credit_type(:mail_content_scan).last
      expect(credit_transaction_mail_content_scan.inbox).to eq(mail_inbox)
      expect(credit_transaction_mail_content_scan.credit_type).to eq('mail_content_scan')
      expect(credit_transaction_mail_content_scan.reason).to eq('subscription')
      expect(credit_transaction_mail_content_scan.amount).to eq(60) # mail_standard
      expect(credit_transaction_mail_content_scan.expires_at).to be_within(1.minute).of(Time.now + 30.days)
      expect(credit_transaction_mail_content_scan.balance).to eq(60)

      credit_transaction_mail_translation_summary = mail_inbox.credit_transactions.with_credit_type(:mail_translation_summary).last
      expect(credit_transaction_mail_translation_summary.inbox).to eq(mail_inbox)
      expect(credit_transaction_mail_translation_summary.credit_type).to eq('mail_translation_summary')
      expect(credit_transaction_mail_translation_summary.reason).to eq('subscription')
      expect(credit_transaction_mail_translation_summary.amount).to eq(60) # mail_standard
      expect(credit_transaction_mail_translation_summary.expires_at).to be_within(1.minute).of(Time.now + 30.days)
      expect(credit_transaction_mail_translation_summary.balance).to eq(60)
    end
  end

end
