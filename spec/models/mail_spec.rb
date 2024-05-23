# == Schema Information
#
# Table name: mails
#
#  id          :bigint           not null, primary key
#  received_on :date
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :bigint
#
# Indexes
#
#  index_mails_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

require 'rails_helper'

RSpec.describe Mail, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
