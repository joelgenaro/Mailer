desc 'Makes a snapshot of various Marketing metrics'
task marketing_metrics_snapshot: :environment do
  # Twitter
  twitter_followers = nil
  begin
    response = HTTParty.get('https://cdn.syndication.twimg.com/widgets/followbutton/info.json?screen_names=tokyomate_')
    twitter_followers = response.parsed_response[0]['followers_count']
  rescue => exception
  end
  
  # Instagram
  instagram_followers = nil
  begin
    response = HTTParty.get('https://www.instagram.com/tokyomate.jp/?__a=1')
    if response.parsed_response.class == Hash
      instagram_followers = response.parsed_response.dig('graphql', 'user', 'edge_followed_by', 'count').try(:to_i) || nil
    end
  rescue => exception
  end
  
  # LinkedIn
  # See also: https://taras.codes/blog/linkedin-organization-follower-count/
  linkedin_followers = nil
  begin
    response = HTTParty.get('https://www.linkedin.com/pages-extensions/FollowCompany?id=31174201&counter=bottom')
    linkedin_followers = response.body.scan(/<div class="follower-count">(.*)<\/div>/)[0][0].gsub(',','').to_i
  rescue => exception
  end
  
  # Facebook
  # See here to get page access token: https://developers.facebook.com/docs/pages/access-tokens/ (should have access to tokyomate.jp page)
  facebook_fans = nil
  begin
    fb_page_access_token = ENV.fetch('MARKETING_METRICS_FB_PAGE_ACCESS_TOKEN')
    response = HTTParty.get("https://graph.facebook.com/v11.0/tokyomate.jp?fields=name%2Cfollowers_count%2Cfan_count&access_token=#{fb_page_access_token}")
    facebook_fans = response.parsed_response['fan_count']
    # fb_followers_count = response.parsed_response['followers_count'] # This is the same number as 'fan_count'
  rescue => exception
  end

  # GetResponse
  get_response_contacts = nil
  begin
    response = HTTParty.get( 'https://api.getresponse.com/v3/contacts', headers: { 'X-Auth-Token' => "api-key #{ENV['GET_RESPONSE_API_KEY']}" })
    get_response_contacts = response.headers['totalcount'].to_i
  rescue => exception
  end

  # Consultation Requests
  consultation_requests = ConsultationRequest.count

  # Make the Snapshot 
  MarketingMetricsSnapshot.create(
    twitter_followers: twitter_followers,
    instagram_followers: instagram_followers,
    linkedin_followers: linkedin_followers,
    facebook_fans: facebook_fans,
    get_response_contacts: get_response_contacts,
    consultation_requests: ConsultationRequest.count
  )
end