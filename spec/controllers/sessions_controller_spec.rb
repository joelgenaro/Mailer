require 'rails_helper'
include AuthHelper

RSpec.describe SessionsController, type: :controller do

  before(:each) do 
    http_login
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  context 'POST #create' do 
    it 'does not clear referrer cookie if invalid details' do
      user = create(:user, password: 'password', password_confirmation: 'password')
      cookies['tkm_referrer'] = 'cic'
      expect(flash['alert']).to be_nil
      expect(controller.current_user).to be_nil
      post :create, params: { 
        user: {
          email: user.email,
          password: 'bad',
        }, locale: 'en'
      }
      expect(flash['alert']).to eq("Invalid Email or password.")
      expect(controller.current_user).to be_nil
      expect(response.headers['Set-Cookie']).to_not include("tkm_referrer")
    end

    it 'does not clear referrer cookie if not existing customer' do 
      user = create(:user, password: 'password', password_confirmation: 'password')
      expect(user.subscriptions).to be_empty
      cookies['tkm_referrer'] = 'cic'
      expect(flash['notice']).to be_nil
      expect(controller.current_user).to be_nil
      post :create, params: { 
        user: {
          email: user.email,
          password: 'password',
        }, locale: 'en'
      }
      expect(flash['notice']).to eq("Signed in successfully.")
      expect(controller.current_user).to eq(user)
      expect(response.headers['Set-Cookie']).to_not include("tkm_referrer")
    end

    it 'clears referrer cookie if existing customer' do 
      user = create(:user, :with_payment_method, password: 'password', password_confirmation: 'password')
      create(:subscription, :with_plan_mail, user: user)
      cookies['tkm_referrer'] = 'cic'
      expect(flash['notice']).to be_nil
      expect(controller.current_user).to be_nil
      post :create, params: { 
        user: {
          email: user.email,
          password: 'password',
        }, locale: 'en'
      }
      expect(flash['notice']).to eq("Signed in successfully.")
      expect(controller.current_user).to eq(user)
      expect(response.headers['Set-Cookie']).to include("tkm_referrer=; path=/; max-age=0; expires=Thu, 01 Jan 1970 00:00:00 GMT")      
    end
  end

  context 'DELETE #destroy' do 
    it 'does not clear referrer cookie if not existing customer' do 
      user = create(:user)
      expect(user.subscriptions).to be_empty
      sign_in user
      cookies['tkm_referrer'] = 'cic'
      expect(flash['notice']).to be_nil
      expect(controller.current_user).to eq(user)
      delete :destroy, params: { locale: 'en'}
      expect(flash['notice']).to eq("Signed out successfully.")
      expect(controller.current_user).to be_nil
      expect(response.headers['Set-Cookie']).to_not include("tkm_referrer")
    end

    it 'clears referrer cookie if existing customer' do 
      user = create(:user, :with_payment_method)
      create(:subscription, :with_plan_mail, user: user)
      sign_in user
      cookies['tkm_referrer'] = 'cic'
      expect(flash['notice']).to be_nil
      expect(controller.current_user).to eq(user)
      delete :destroy, params: { locale: 'en'}
      expect(flash['notice']).to eq("Signed out successfully.")
      expect(controller.current_user).to be_nil
      expect(response.headers['Set-Cookie']).to include("tkm_referrer=; path=/; max-age=0; expires=Thu, 01 Jan 1970 00:00:00 GMT")      
    end
  end
end