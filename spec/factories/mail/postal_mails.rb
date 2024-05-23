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

FactoryBot.define do
  factory :mail_postal_mail, class: 'Mail::PostalMail' do
    association :mail_recipient, factory: :mail_recipient

    notes { "Some notes" }
    received_on { Time.now }
    state { "unopened" }

    after(:build) do |postal_mail|
      postal_mail.mail_items << build(:mail_mail_item, postal_mail: nil) if postal_mail.mail_items.empty?
      postal_mail.mail_recipient = postal_mail.inbox.recipients.last if postal_mail.inbox
    end
  end
end
