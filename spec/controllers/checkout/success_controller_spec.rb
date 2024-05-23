require 'rails_helper'
include AuthHelper
RSpec.describe Checkout::SuccessController, type: :controller do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before { 
    http_login
    @user = create(:user)
    @growth_referrer_cic = create(:growth_referrer, :with_code_cic)
    StripeMock.start 
  }
  after { StripeMock.stop }

  context 'POST #index' do 
    before(:each) do 
      # On each request, should get stripe session and setup account
      expect(Stripe::Checkout::Session).to receive(:retrieve).with('whoaDUDE57').exactly(1).times.and_return(OpenStruct.new({
        metadata: OpenStruct.new({
          subscription_name: 'mail_pro',
          subscription_type: 'mail'
        }),
        amount_total: 123,
        customer: 'cus_1111',
        subscription: 'sub_2222'
      }))

      doubleSetupAccountNew = double(do: true)
      expect(SetupAccount).to receive(:new).once.with(
        @user,
        'mail_pro',
        'mail',
        'cus_1111',
        'sub_2222'
      ).and_return(doubleSetupAccountNew)
      expect(doubleSetupAccountNew).to receive(:do)
    end

    it 'sets up user account' do 
      expect(@user.growth_referrer).to be_nil
      expect(@growth_referrer_cic.conversions).to eq(0)

      # High expectations for Slack message
      expect(SlackNotificationJob).to receive(:perform_later).with(
        "*New Subscription:* #{@user.email} has created subscription: mail : mail_pro (from onboarding). [View user](http://test.host/boxm293/admin/users/1). "
      ).once

      # Make request
      sign_in @user
      post :index, params: { 
        session_id: 'whoaDUDE57'
      }

      # Flash notice and JS tracking
      expect(flash.to_h).to eq({
        "notice" => "Thanks, your subscription has been setup.", 
        "track_subscription_created" => {
          :new_user => true, 
          :user_id => @user.id, 
          :subscription_name => "mail_pro", 
          :subscription_type => "mail", 
          :gtag_value => 123.0
        }
      })

      # Does not increment any growth referrer, as not referer
      @growth_referrer_cic.reload
      expect(@growth_referrer_cic.conversions).to eq(0)
    end

    it 'increments growth referrer conversions' do
      growth_referrer_other = create(:growth_referrer, code: 'other')
      @user.update(growth_referrer: @growth_referrer_cic)
      expect(@growth_referrer_cic.conversions).to eq(0)

      # Includes in Slack message
      expect(SlackNotificationJob).to receive(:perform_later).with(
        "*New Subscription:* #{@user.email} has created subscription: mail : mail_pro (from onboarding)(Referrer `cic` #1). [View user](http://test.host/boxm293/admin/users/#{@user.id}). "
      ).once

      # Make request
      sign_in @user
      cookies['tkm_referrer'] = 'cic'
      post :index, params: { 
        session_id: 'whoaDUDE57'
      }

      # Clears referrer cookie
      expect(response.cookies[:tkm_referrer]).to be_nil
      expect(response.headers['Set-Cookie']).to include("tkm_referrer=; path=/; max-age=0; expires=Thu, 01 Jan 1970 00:00:00 GMT")

      # Flash notice and JS tracking
      expect(flash.to_h).to eq({
        "notice" => "Thanks, your subscription has been setup.", 
        "track_subscription_created" => {
          :new_user => true, 
          :user_id => @user.id, 
          :subscription_name => "mail_pro", 
          :subscription_type => "mail", 
          :gtag_value => 123.0
        }
      })

      # Does not increment any growth referrer, only CIC
      @growth_referrer_cic.reload
      expect(@growth_referrer_cic.conversions).to eq(1)
      growth_referrer_other.reload
      expect(growth_referrer_other.conversions).to eq(0)
    end
  end
end