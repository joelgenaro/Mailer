# == Schema Information
#
# Table name: growth_referrers
#
#  id          :bigint           not null, primary key
#  code        :string
#  conversions :integer          default(0)
#  parameters  :jsonb
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_growth_referrers_on_code  (code)
#

require 'rails_helper'

RSpec.describe Growth::Referrer, type: :model do
  
  context 'Validations' do 
    it 'code' do 
      should_not allow_value(nil).for(:code)
      should_not allow_value('').for(:code)
      should validate_uniqueness_of(:code)
    end

    it 'conversions' do 
      should_not allow_value(nil).for(:conversions)
    end
  end
end
