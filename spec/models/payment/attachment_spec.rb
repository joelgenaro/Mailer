# == Schema Information
#
# Table name: payment_attachments
#
#  id                :bigint           not null, primary key
#  description       :string
#  file_content_type :string
#  file_file_name    :string
#  file_file_size    :bigint
#  file_updated_at   :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  payment_id        :bigint
#
# Indexes
#
#  index_payment_attachments_on_payment_id  (payment_id)
#
# Foreign Keys
#
#  fk_rails_...  (payment_id => payments.id)
#

require 'rails_helper'

RSpec.describe Payment::Attachment, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
