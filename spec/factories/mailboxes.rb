# == Schema Information
#
# Table name: mailboxes
#
#  id                    :bigint           not null, primary key
#  address_en            :string
#  address_jp            :string
#  auto_open_mail        :boolean          default(FALSE)
#  auto_pay_bills        :boolean          default(FALSE)
#  auto_pay_limit_amount :integer          default(30000), not null
#  last_checked_at       :datetime
#  name                  :string           default("inbox")
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  user_id               :bigint
#
# Indexes
#
#  index_mailboxes_on_user_id  (user_id)
#

FactoryBot.define do
  factory :mailbox do
    
  end
end
