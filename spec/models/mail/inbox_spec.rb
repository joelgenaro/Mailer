# == Schema Information
#
# Table name: inboxes
#
#  id                                :bigint           not null, primary key
#  auto_open_mail                    :boolean          default(FALSE)
#  auto_pay_bills                    :boolean          default(FALSE)
#  auto_pay_limit_amount             :integer          default(30000), not null
#  auto_pay_limit_is_unlimited       :boolean          default(FALSE)
#  credits_balance_last_processed_at :datetime
#  last_checked_at                   :datetime
#  onboarding_status                 :string
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  user_id                           :bigint
#
# Indexes
#
#  index_inboxes_on_user_id  (user_id)
#

require 'rails_helper'

RSpec.describe Mail::Inbox, type: :model do
  
  context 'Relationships' do 
    it 'user' do 
      should belong_to(:user)
    end

    it 'postal_mails' do 
      should have_many(:postal_mails).dependent(:destroy)
    end

    it 'bills' do 
      should have_many(:bills).through(:postal_mails)
    end

    it 'recipients' do 
      should have_many(:recipients).dependent(:destroy)
    end

    it 'credit_transactions' do 
      should have_many(:credit_transactions).dependent(:destroy)
    end
  end
  
end
