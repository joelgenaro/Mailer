# == Schema Information
#
# Table name: receptionist_accounts
#
#  id               :bigint           not null, primary key
#  google_drive_url :string
#  google_sheet_url :string
#  phone_number     :string
#  status           :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  user_id          :bigint
#
# Indexes
#
#  index_receptionist_accounts_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

FactoryBot.define do
  factory :receptionist_account, class: 'Receptionist::Account' do
    association :user, factory: :user
    
    # Default: Not setup
    status { "not_setup" }
    phone_number { nil }
    google_drive_url { nil }
    google_sheet_url { nil }

    trait :setup do 
      status { "setup" }
      phone_number { "03-4405-2796" }
      google_drive_url { "https://drive.google.com/drive/folders/xyz" }
      google_sheet_url { "https://docs.google.com/spreadsheets/d/xyz" }
    end
  end
end
