# Controller Helper for, umm, testing controllers
# https://github.com/heartcombo/devise/wiki/How-To:-Test-controllers-with-Rails-(and-RSpec)#controller-specs
module ControllerHelper
  def expect_redirect_to_login_page
    expect(response).to have_http_status(302)
    expect(response.redirect_url).to eq('http://test.host/users/sign_in')
    expect(flash[:alert]).to eq('You need to sign in or sign up before continuing.')
  end

  def expect_json_unauthorized_response
    expect(response).to have_http_status(401)
    expect(response.body).to eq('{"error":"You need to sign in or sign up before continuing."}')
  end
end