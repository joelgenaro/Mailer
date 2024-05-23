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

FactoryBot.define do
  factory :mail_recipient, class: 'Mail::Recipient' do
    association :inbox, factory: :mail_inbox
    name { "Rick #{SecureRandom.hex(2)} Sanchez" }
    after(:build) do |mail_recipient|
      mail_recipient.address_en = "#{mail_recipient.name}, Crea Landmark 305, 2-9 Reisenmachi, Hakata Ward, Fukuoka 8120039 Japan"
      mail_recipient.address_jp = "〒812-0039 福岡県福岡市博多区冷泉町2-9 クレアランドマーク305 #{mail_recipient.name}"
    end
  end
end
