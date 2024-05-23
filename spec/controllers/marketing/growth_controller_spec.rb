require 'rails_helper'

RSpec.describe Marketing::GrowthController, type: :controller do
  include AuthHelper
  before(:each) do
    http_login
  end
  describe "GET #referrer" do
    before(:all) do 
      @growth_referrer = create(:growth_referrer, :with_code_cic)
    end

    it 'route' do 
      should route(:get, '/referrer/cic').to(action: :referrer, code: 'cic', locale: 'en')
      should route(:get, '/referrer/foobar').to(action: :referrer, code: 'foobar',  locale: 'en')
    end

    it "drops cookie and redirects" do
      Timecop.freeze("2021-10-28T15:57:23+00:00") do
        get :referrer, params: { code: 'cic', locale: 'en'}
        expect(controller.current_user).to be_nil # Double check not signed in
        expect(response.status).to eq(302)
        expect(response.headers['Location']).to eq('http://test.host/pricing/mail')
        expect(flash.to_h).to eq({})
        expect(response.cookies['tkm_referrer']).to eq('cic')
        expect(response.headers['Set-Cookie']).to include('tkm_referrer=cic; path=/; expires=Thu, 04 Nov 2021 15:57:23 GMT')
      end
    end

    context 'ensures valid referrer code' do 
      it 'invalid' do 
        ['', ' ', '   ', '*', 'bad'].each do |value| 
          get :referrer, params: { code: 'value', locale: 'en'}
          expect(response.status).to eq(302)
          expect(response.headers['Location']).to eq('http://test.host/')
          expect(flash.to_h).to eq({"notice"=>"Invalid referrer"})
          expect(response.cookies['tkm_referrer']).to be_nil
          expect(response.headers['Set-Cookie']).to_not include('tkm_referrer')
        end
      end

      it 'handles downcases' do
        Timecop.freeze("2021-10-28T15:57:23+00:00") do
          get :referrer, params: { code: 'CiC' , locale: 'en'}
          expect(response.status).to eq(302)
          expect(response.headers['Location']).to eq('http://test.host/pricing/mail')
          expect(flash.to_h).to eq({})
          expect(response.cookies['tkm_referrer']).to eq('cic')
          expect(response.headers['Set-Cookie']).to include('tkm_referrer=cic; path=/; expires=Thu, 04 Nov 2021 15:57:23 GMT')
        end
      end
    end

    it 'ignores existing customers' do 
      Timecop.freeze("2021-10-28T15:57:23+00:00") do
        user = create(:user, :with_payment_method)
        sign_in user

        # No subscriptions, so new customer
        get :referrer, params: { code: 'cic', locale: 'en'}
        expect(response.status).to eq(302)
        expect(response.headers['Location']).to eq('http://test.host/pricing/mail')
        expect(flash.to_h).to eq({})
        expect(response.cookies['tkm_referrer']).to eq('cic')
        expect(response.headers['Set-Cookie']).to include('tkm_referrer=cic; path=/; expires=Thu, 04 Nov 2021 15:57:23 GMT')

        # Has subscriptions, not allowed
        subscription = create(:subscription, :with_plan_assistant, user: user)
        get :referrer, params: { code: 'cic', locale: 'en'}
        expect(response.status).to eq(302)
        expect(response.headers['Location']).to eq('http://test.host/')
        expect(flash.to_h).to eq({"notice"=>"Only available for new customers"})
        expect(response.cookies['tkm_referrer']).to be_nil
        expect(response.headers['Set-Cookie']).to_not include('tkm_referrer')
      end
    end
  end

end
