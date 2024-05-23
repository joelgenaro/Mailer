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
  factory :mail_mail_item, class: 'Mail::MailItem' do
    association :postal_mail, factory: :mail_postal_mail
    path_to_test_image = "app/assets/images/frontend/sample-bills/water-bill.jpg"
    file { Rack::Test::UploadedFile.new(path_to_test_image) }
    file_content_type { 'application/pdf' }
    file_file_name { 'test.pdf' }
    file_file_size { 1024 }
    file_updated_at { Time.now }
  end
end
