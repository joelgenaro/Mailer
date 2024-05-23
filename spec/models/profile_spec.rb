# == Schema Information
#
# Table name: profiles
#
#  id             :bigint           not null, primary key
#  address_line_1 :string
#  address_line_2 :string
#  building_name  :string
#  display_name   :string
#  first_name     :string
#  isforeign      :boolean          default(FALSE)
#  last_name      :string
#  occupation     :string
#  phone_number   :string
#  postal_code_1  :string
#  postal_code_2  :string
#  prefecture     :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  user_id        :bigint
#
# Indexes
#
#  index_profiles_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

require 'rails_helper'

RSpec.describe Profile, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
