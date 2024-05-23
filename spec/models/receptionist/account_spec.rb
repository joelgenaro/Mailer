# == Schema Information
#
# Table name: receptionist_accounts
#
#  id               :bigint           not null, primary key
#  google_drive_url :string
#  google_sheet_url :string
#  phone_number     :string
#  status           :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  user_id          :bigint
#
# Indexes
#
#  index_receptionist_accounts_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

require 'rails_helper'

RSpec.describe Receptionist::Account, type: :model do
  context 'Validations' do 
    subject { build(:receptionist_account)  }

    it 'user' do 
      # Required
      should belong_to(:user)
      should_not allow_value(nil).for (:user)
      should_not belong_to(:user).dependent(:destroy)
    end
    
    it 'phone_number' do 
      # Optional if not setup
      receptionist_account = build(:receptionist_account)
      expect(receptionist_account.status).to eq('not_setup')
      receptionist_account.phone_number  = nil
      expect(receptionist_account.valid?).to eq(true)

      # Required if setup
      receptionist_account = build(:receptionist_account, :setup)
      expect(receptionist_account.status).to eq('setup')
      receptionist_account.phone_number = nil
      expect(receptionist_account.valid?).to eq(false)
      expect(receptionist_account.errors.full_messages).to include("Phone number can't be blank")
    end

    it 'google_drive_url' do 
      # Optional if not setup
      receptionist_account = build(:receptionist_account)
      expect(receptionist_account.status).to eq('not_setup')
      receptionist_account.google_drive_url  = nil
      expect(receptionist_account.valid?).to eq(true)

      # Required if setup
      receptionist_account = build(:receptionist_account, :setup)
      expect(receptionist_account.status).to eq('setup')
      receptionist_account.google_drive_url = nil
      expect(receptionist_account.valid?).to eq(false)
      expect(receptionist_account.errors.full_messages).to include("Google drive url can't be blank")
    end

    it 'google_sheet_url' do 
      # Optional if not setup
      receptionist_account = build(:receptionist_account)
      expect(receptionist_account.status).to eq('not_setup')
      receptionist_account.google_sheet_url  = nil
      expect(receptionist_account.valid?).to eq(true)

      # Required if setup
      receptionist_account = build(:receptionist_account, :setup)
      expect(receptionist_account.status).to eq('setup')
      receptionist_account.google_sheet_url = nil
      expect(receptionist_account.valid?).to eq(false)
      expect(receptionist_account.errors.full_messages).to include("Google sheet url can't be blank")
    end
  end

  context 'State Machines' do 
    context 'Status' do 
      it 'defaults to not_setup' do
        receptionist_account = Receptionist::Account.new
        expect(receptionist_account.status).to eq('not_setup')
      end

      it 'transitions to setup' do 
        receptionist_account = create(:receptionist_account)
        expect(receptionist_account.status).to eq('not_setup')
        expect(receptionist_account.phone_number).to be_nil
        expect(receptionist_account.google_drive_url).to be_nil
        expect(receptionist_account.google_sheet_url).to be_nil

        # Validation issue if attributes blank
        expect(receptionist_account.setup).to eq(false)
        expect(receptionist_account.status).to eq('not_setup')

        receptionist_account.phone_number = '0344052795'
        expect(receptionist_account.setup).to eq(false)
        expect(receptionist_account.status).to eq('not_setup')

        receptionist_account.google_drive_url = 'something'
        expect(receptionist_account.setup).to eq(false)
        expect(receptionist_account.status).to eq('not_setup')

        receptionist_account.google_sheet_url = 'something_else'
        expect(receptionist_account.setup).to eq(true)
        expect(receptionist_account.status).to eq('setup')
      end
    end
  end

  context 'Guards' do 
    it 'guard_can_setup?' do
      receptionist_account = build(:receptionist_account)
      expect(receptionist_account.phone_number).to be_nil
      expect(receptionist_account.google_drive_url).to be_nil
      expect(receptionist_account.google_sheet_url).to be_nil
      expect(receptionist_account.guard_can_setup?).to eq(false)
      expect(receptionist_account.guard_can_setup?(true)).to eq('Missing information')

      receptionist_account.phone_number = '0344052795'
      expect(receptionist_account.guard_can_setup?).to eq(false)

      receptionist_account.google_drive_url = 'something'
      expect(receptionist_account.guard_can_setup?).to eq(false)

      receptionist_account.google_sheet_url = 'something_else'
      expect(receptionist_account.guard_can_setup?).to eq(true)
      expect(receptionist_account.guard_can_setup?(true)).to eq(true)
    end
  end
end
