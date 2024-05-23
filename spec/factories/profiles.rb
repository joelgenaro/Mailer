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

FactoryBot.define do
  factory :profile do
    association :user, factory: :user
    first_name { "Spike" }
    last_name { "Spiegel" }
    occupation { "Space Cowboy" }
    phone_number { "75 518 2603" }
  end
end
