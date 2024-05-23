# == Schema Information
#
# Table name: mail_recipients
#
#  id         :bigint           not null, primary key
#  address_en :string
#  address_jp :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  inbox_id   :bigint
#
# Indexes
#
#  index_mail_recipients_on_inbox_id  (inbox_id)
#
# Foreign Keys
#
#  fk_rails_...  (inbox_id => inboxes.id)
#

require 'rails_helper'

RSpec.describe Mail::Recipient, type: :model do
  context 'Relationships' do 
    it 'inbox' do 
      should belong_to(:inbox)
      should_not allow_value(nil).for (:inbox)
      should_not belong_to(:inbox).dependent(:destroy)
    end
  end

  context 'Validations' do 
    it 'name' do 
      should validate_presence_of(:name)
      should validate_uniqueness_of(:name).case_insensitive.scoped_to(:address_en)
    end

    it 'address_en' do 
      should validate_presence_of(:address_en)
      should validate_uniqueness_of(:address_en).case_insensitive
    end

    it 'address_jp' do 
      should validate_presence_of(:address_jp)
      should validate_uniqueness_of(:address_jp).case_insensitive
    end
  end

  context 'Methods' do
    it 'self.build' do
      user = create(:user)
      mail_inbox = create(:mail_inbox, user: user)

      # No name, use inbox id
      recipient_1 = Mail::Recipient.build(mail_inbox)
      expect(recipient_1.inbox).to eq(mail_inbox)
      expect(recipient_1.name).to eq(user.id.to_s)
      expect(recipient_1.address_en).to eq("ID #{user.id}, Crea Landmark 305, 2-9 Reisenmachi, Hakata Ward, Fukuoka 8120039 Japan")
      expect(recipient_1.address_jp).to eq("〒812-0039 福岡県福岡市博多区冷泉町2-9 クレアランドマーク305-#{user.id}")
      expect(recipient_1.persisted?).to eq(false)

      # Use name
      recipient_2 = Mail::Recipient.build(mail_inbox, "Jockus Zoorealmer")
      expect(recipient_2.inbox).to eq(mail_inbox)
      expect(recipient_2.name).to eq("Jockus Zoorealmer")
      expect(recipient_2.address_en).to eq("Jockus Zoorealmer, Crea Landmark 305, 2-9 Reisenmachi, Hakata Ward, Fukuoka 8120039 Japan")
      expect(recipient_2.address_jp).to eq("〒812-0039 福岡県福岡市博多区冷泉町2-9 クレアランドマーク305 Jockus Zoorealmer")
      expect(recipient_2.persisted?).to eq(false)
    end
  end
end
