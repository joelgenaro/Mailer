# Helpers working with Bebop's GraphQL 
module BebopGraphQLHelper 
  # Ensures admin authentication for provided query
  # by making a request unauthenticated and then
  # again as authenticated as a User, in both cases
  # ensuring a redirect to admin login is returned
  def ensure_admin_user_authenticated(query)
    # Unauthenticated
    post(
      '/boxm293/bebop/graphql',
      params: { query: query },
      headers: { }
    )
    expect(response.headers['Location']).to eq("http://www.example.com/boxm293/admin/login")
    expect(response.status).to eq(302)

    # As User (not AdminUser)
    user = create(:user)
    authorized_request(user, query)
    expect(response.headers['Location']).to eq("http://www.example.com/boxm293/admin/login")
    expect(response.status).to eq(302)
  end
  
  # Makes a request for provided query, 
  # authenticated as provided AdminUser
  def authorized_request(admin_user, query) 
    sign_in admin_user
    post(
      '/boxm293/bebop/graphql',
      params: { query: query },
      headers: { }
    )
  end

  # Expects provided json to have an error body and
  # contain the provided attributes
  # @param [Hash] json JSON response body 
  # @param [String] code Error Code
  # @param [String] message Error message
  def expect_request_error(json, code, message)
    json['data'].each{|k,v| expect(json['data'][k]).to be_nil} if !json['data'].nil?
    expect(json['errors'].count).to eq(1)
    expect(json['errors'][0]).to include(
      'message' => message,
      'extensions' => {
        'code' => code
      }
    )
  end

  # Expects the provided json body to contain the 
  # not found response
  # @params json [Hash] JSON response body
  def expect_not_found_error(json)
    expect_request_error(json, 'recordNotFound', 'Record not found')
  end
end