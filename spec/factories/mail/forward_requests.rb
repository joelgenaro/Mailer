# == Schema Information
#
# Table name: mail_forward_requests
#
#  id             :bigint           not null, primary key
#  address        :string
#  forwarded_at   :datetime
#  requested_at   :datetime
#  state          :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  postal_mail_id :bigint
#
# Indexes
#
#  index_mail_forward_requests_on_postal_mail_id  (postal_mail_id)
#
# Foreign Keys
#
#  fk_rails_...  (postal_mail_id => postal_mails.id)
#

FactoryBot.define do
  factory :mail_forward_request, class: 'Mail::ForwardRequest' do
    postal_mail { nil }
    address { "MyString" }
    state { "MyString" }
    requested_at { "2020-11-02 12:15:11" }
    forwarded_at { "2020-11-02 12:15:11" }
  end
end
