# Sentry.configure do |config|
#   config.dsn = ENV.fetch('SENTRY_DSN_RAILS')
#   config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
#   config.environments = ['staging', 'production']
#   config.release = ENV['HEROKU_RELEASE_VERSION'] || ''
#   config.processors -= [Sentry::Processor::PostData]
# end

Sentry.init do |config|
  config.dsn = ENV.fetch('SENTRY_DSN_RAILS')
  config.environment = ['staging', 'production']
  config.release = ENV['HEROKU_RELEASE_VERSION'] || ''
  config.breadcrumbs_logger = [:sentry_logger, :http_logger]

  # To activate performance monitoring, set one of these options.
  # We recommend adjusting the value in production:
  config.traces_sample_rate = 1.0
  # or
  config.traces_sampler = lambda do |context|
    0.5
  end
end