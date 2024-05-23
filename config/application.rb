require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Mailmate
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Use Sidekiq for jobs - https://github.com/mperham/sidekiq/wiki/Active+Job
    config.active_job.queue_adapter = :sidekiq

    # Use our own routes for exception pages
    config.exceptions_app = self.routes

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # image variants and pdf file preview
    config.active_storage.variant_processor = :mini_magick
    config.active_storage.previewers
    Rails.application.config.active_storage.previewers << ActiveStorage::Previewer::PopplerPDFPreviewer

    # translation fallback
    config.i18n.fallbacks = true
  end
end
