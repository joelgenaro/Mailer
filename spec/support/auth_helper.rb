module AuthHelper
    def http_login
        user = ENV['BASIC_AUTH_USERNAME']
        pwd = ENV['BASIC_AUTH_PASSWORD']
        request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(user,pwd)
    end  
  end