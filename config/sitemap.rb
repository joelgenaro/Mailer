require 'aws-sdk-s3'

# A note on Google Search Console.
# Because Google Search Console is stupid and will not allow offsite sitemaps (eg hosted on S3), 
# we have to pretend we host it and 301 redirect to the S3 host. This redirect is setup in the routes file,
# so we just generate the sitemap index pointing to other sitemaps on the base url ('https://tokyomate.jp') 
# and routes will redirect to S3

# Configuration
SitemapGenerator::Sitemap.default_host = ENV.fetch('SITEMAP_HOST') # Set the host name for URL creation (our website), eg 'https://tokyomate.jp'
SitemapGenerator::Sitemap.sitemaps_host =  ENV.fetch('SITEMAP_HOST') # This should also be the same host name, due to our redirection logic
SitemapGenerator::Sitemap.sitemaps_path = "sitemaps" # Set this to a directory/path if you don't want to upload to the root of your `sitemaps_host`
SitemapGenerator::Sitemap.public_path = 'tmp/' # The directory to write sitemaps to locally

# Remote host upload
# https://github.com/kjvarga/sitemap_generator#upload-sitemaps-to-a-remote-host-using-adapters
if Rails.env.production?
  SitemapGenerator::Sitemap.adapter = SitemapGenerator::AwsSdkAdapter.new(
    ENV.fetch('AWS_S3_BUCKET_NAME'),
    aws_access_key_id: ENV.fetch('AWS_S3_ACCESS_KEY_ID'),
    aws_secret_access_key: ENV.fetch('AWS_S3_SECRET_ACCESS_KEY'),
    aws_region: ENV.fetch('AWS_S3_REGION')
  )
end

SitemapGenerator::Sitemap.create do
  # Static Pages
  add '/', changefreq: 'weekly', priority: 1
  # add '/mail', changefreq: 'weekly', priority: 0.95
  add '/assistant', changefreq: 'weekly', priority: 0.95
  add '/pricing/mail', changefreq: 'weekly', priority: 0.95
  add '/consultation', changefreq: 'weekly', priority: 0.95
  add '/faq', changefreq: 'weekly', priority: 0.90
  add '/about', changefreq: 'weekly', priority: 0.90
  add '/ja', changefreq: 'weekly', priority: 1
  #add '/ja/pricing/mail', changefreq: 'weekly', priority: 0.95
  add '/ja/consultation', changefreq: 'weekly', priority: 0.95
  add '/ja/faq', changefreq: 'weekly', priority: 0.90
  add '/ja/about', changefreq: 'weekly', priority: 0.90
  
  # Blog (incl posts, categories & authors)
  contentful_client = Contentful::Client.new(
    space: ENV['CONTENTFUL_SPACE_ID'],
    access_token: ENV['CONTENTFUL_ACCESS_TOKEN'],
    api_url: ENV['CONTENTFUL_API_URL'],
    dynamic_entries: :auto,
    raise_errors: true
  )
  add '/blog', changefreq: 'weekly', priority: 0.85

  # Even 200 Blogposts caused Contentful::BadRequest (HTTP status code: 400 Bad Request)
  # with Message: Response size too big. Maximum allowed response size: 7340032B.
  # Get the entries in 100 limit batches
  ContentfulEntriesService.get_entries_in_batches({ client: contentful_client, order: '-fields.publishedOn'}).each do |entry|
    add marketing_blog_post_path(entry.slug), changefreq: 'weekly', priority: 0.7
  end

  # for blog_post_Japanese
  ContentfulEntriesService.get_entries_in_batches({ client: contentful_client, content_type: 'blogPostJapanese' ,order: '-fields.publishedOn'}).each do |entry|
    add marketing_blog_post_ja_path(entry.slug), changefreq: 'weekly', priority: 0.7
  end
  
  contentful_client.entries(content_type: 'blogCategory', limit: 1000).each do |category|
    add marketing_blog_category_path(category.slug), changefreq: 'weekly', priority: 0.7
  end
  contentful_client.entries(content_type: 'blogPostAuthor', limit: 1000).each do |author|
    add marketing_blog_author_path(author.slug), changefreq: 'weekly', priority: 0.7
  end

  add '/service-directory', changefreq: 'weekly', priority: 0.85
  contentful_client.entries(content_type: 'serviceCategory').each do |category|
    add marketing_show_category_listings_path(category.slug), changefreq: 'weekly', priority: 0.7
  end
  contentful_client.entries(content_type: 'businessProfile').each do |listing|
    add marketing_show_service_listing_path(slug: listing.slug), changefreq: 'weekly', priority: 0.7
  end
end