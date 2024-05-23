require 'rails_helper'

RSpec.describe ContentfulEntriesService, type: :service do
  let(:contentful_client) {
    # in local test environment, contentful may not be set
    return nil if ENV.has_key?('TESTS_SKIP_CONTENTFUL')

    Contentful::Client.new(
        space: ENV['CONTENTFUL_SPACE_ID'],
        access_token: ENV['CONTENTFUL_ACCESS_TOKEN'],
        api_url: ENV['CONTENTFUL_API_URL'],
        dynamic_entries: :auto,
        raise_errors: true
  )}

  it 'returns correct count of posts' do 
    next if contentful_client.nil?
    total= ContentfulEntriesService.get_entries_in_batches({
      client: contentful_client,
    }).count
    expect(total).to be >0
    expect(contentful_client.entries(content_type: 'blogPost', order: '-fields.publishedOn', limit: 100, skip: total).count).to eq(0)
  end

end