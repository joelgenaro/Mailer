# All Environments
Dotenv.require_keys(
  # Action Mailer
  'ACTION_MAILER_HOST',

  # Appication URL,
  'APPLICATION_URL',

  # Google Analytics & Adwords
  'GTAGS_ANALYTICS_ID',
  'GTAGS_ADWORDS_ID',

  # Intercom
  'INTERCOM_APP_ID',

  # Redis
  'REDIS_URL',

  # Stripe
  'STRIPE_PUBLISHABLE_KEY',
  'STRIPE_SECRET_KEY',
  'STRIPE_WEBHOOK_SECRET',

  # Sitemap
  "SITEMAP_HOST",
  "SITEMAP_S3_URL",

  # Contentful
  'CONTENTFUL_ACCESS_TOKEN',
  'CONTENTFUL_SPACE_ID',
  'CONTENTFUL_API_URL',

  # OTP Secret Encryption Key
  'OTP_SECRET_ENCRYPTION_KEY',

  # Get Response
  'GET_RESPONSE_API_KEY',
  'GET_RESPONSE_LIST_TOKEN',

  # Mailer configuration:
  'MAILER_DEFAULT_FROM_ADDRESS'
)

# Production
if Rails.env.production?
  Dotenv.require_keys(
    # Admin Emails
    'ADMIN_EMAILS',

    # Asset Host
    'ASSET_HOST',

    # Mailgun
    'MAILGUN_API_KEY',
    'MAILGUN_DOMAIN',

    # Sentry
    'SENTRY_DSN_RAILS',
    'SENTRY_DSN_JS',

    # AWS
    'AWS_S3_ACCESS_KEY_ID',
    'AWS_S3_SECRET_ACCESS_KEY',
    'AWS_S3_BUCKET_NAME',
    'AWS_S3_REGION',
    # 'AWS_CLOUDFRONT_ENDPOINT'

    # Sidekiq Web UI
    "SIDEKIQ_WEB_USERNAME",
    "SIDEKIQ_WEB_PASSWORD",

    # Slack Webhook URL
    "SLACK_NOTIFICATIONS_WEBHOOK_URL",

    # FB Page Access Token For Marketing Reporting
    "MARKETING_METRICS_FB_PAGE_ACCESS_TOKEN"
  )
end
