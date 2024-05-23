# == Schema Information
#
# Table name: mail_items
#
#  id                :bigint           not null, primary key
#  file_content_type :string
#  file_file_name    :string
#  file_file_size    :bigint
#  file_updated_at   :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  postal_mail_id    :bigint
#
# Indexes
#
#  index_mail_items_on_postal_mail_id  (postal_mail_id)
#
# Foreign Keys
#
#  fk_rails_...  (postal_mail_id => postal_mails.id)
#

FactoryBot.define do
  factory :mail_item do
    mail { nil }
  end
end
