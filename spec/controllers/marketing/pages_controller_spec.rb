require 'rails_helper'

RSpec.describe Marketing::PagesController, type: :controller do
  include AuthHelper
  before(:each) do
    http_login
  end
  describe "GET #pricing" do
    it 'redirect blank pricing param to mail pricing' do
      get :pricing, params: {page: '', locale: 'en'}
      expect(response.redirect_url).to eq('http://test.host/pricing/mail')
    end
    it 'redirect invalid pricing pages to home' do
      # get :pricing, params: {page: 'assistant', locale: 'en'}
      # expect(response.redirect_url).to eq('http://test.host/')
      get :pricing, params: {page: 'random_test', locale: 'en'}
      expect(response.redirect_url).to eq('http://test.host/')
    end
  end

end
