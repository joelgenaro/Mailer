# Helpers working with TokyoMate's GraphQL 
module MailmateGraphQLHelper 
  # Makes a request for provided query, 
  # authenticated as provided User
  def authorized_request(user, query) 
    sign_in user
    post(
      '/graphql',
      params: { query: query },
      headers: { }
    )
  end

  # Ensures admin authentication for provided query
  # by making a request unauthenticated and then
  # again as authenticated as a AdminUser, in both cases
  # ensuring a redirect to user login is returned
  def ensure_user_authenticated(query)
    # Unauthenticated
    post('/graphql', params: { query: query }, headers: { })
    expect_request_error(response.parsed_body, 'authentication_required', 'Please authenticate')

    # As AdminUser (not User)
    admin_user = create(:admin_user)
    authorized_request(admin_user, query)
    expect_request_error(response.parsed_body, 'authentication_required', 'Please authenticate')
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
end