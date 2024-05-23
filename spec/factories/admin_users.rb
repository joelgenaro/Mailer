# == Schema Information
#
# Table name: admin_users
#
#  id                        :bigint           not null, primary key
#  consumed_timestep         :integer
#  email                     :string           default(""), not null
#  encrypted_otp_secret      :string
#  encrypted_otp_secret_iv   :string
#  encrypted_otp_secret_salt :string
#  encrypted_password        :string           default(""), not null
#  otp_required_for_login    :boolean          default(TRUE)
#  remember_created_at       :datetime
#  reset_password_sent_at    :datetime
#  reset_password_token      :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
# Indexes
#
#  index_admin_users_on_email                 (email) UNIQUE
#  index_admin_users_on_reset_password_token  (reset_password_token) UNIQUE
#

FactoryBot.define do
  factory :admin_user do
    email { 'admin'+rand(1...9999999).to_s+'@example.com' }
    password  { 'password' }
    password_confirmation { 'password' }
  end
end
