source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }
ruby '3.1.2'

# Application
gem 'rails', '~> 7.0' # Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"
# Use postgresql as the database for Active Record
gem 'pg'
gem 'sqlite3'              
# Use Puma as the app server
gem 'puma'
# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap'

gem 'sass-rails'      # Use SCSS for stylesheets
gem 'sass'
gem 'jbuilder'        # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'redis', '~> 4.0' # Use Redis adapter to run Action Cable in production
gem 'sidekiq'         # Simple, efficient background processing for Ruby
gem 'kaminari'        # A Scope & Engine based paginator for modern web app frameworks and ORMs
gem 'ransack'         # Object-based searching
gem 'money-rails'     # Integration of RubyMoney - Money with Rails
gem 'dotiw'           # Better `distance_of_time_in_words` helper
gem 'activerecord_where_assoc' # Easy to do conditions based on the associations of your records
gem 'route_translator'# Translates the Rails routes of your application into the languages defined in your locale files

# UI
gem 'react-rails' # Render components in views or controller actions
gem 'rails-assets-tether', source: 'https://rails-assets.org'
gem 'inline_svg'  # Get an SVG into your view and then style it with CSS
gem 'bootstrap-sass'
gem 'clipboard-rails'
gem 'hamburgers'

# Data
gem 'aasm' # State machines for Ruby classes
gem 'kt-paperclip' # Easy upload management for ActiveRecord
gem 'enumerize' # Decent enums! Enumerated attributes with I18n and ActiveRecord support
gem 'gon' # Your Rails variables in your JS
gem 'graphql' # A Ruby implementation of GraphQL
gem 'sitemap_generator' # XML Sitemap generator 
gem 'shortcode' # WordPress-like shortcode parsing
gem 'caxlsx' # xlsx spreadsheet generation
gem 'caxlsx_rails' # Caxlsx_Rails provides an Caxlsx renderer so you can move all your spreadsheet code from your controller into view files
gem 'rqrcode' # library for encoding QR Codes and then render them in the way you choose
gem 'combine_pdf' # To parse PDF files and combine (merge) them with other PDF files
gem 'paperclip-ghostscript'  # For thumbnail generation of pdfs
gem 'wicked_pdf'  # Wicked PDF uses the shell utility wkhtmltopdf to serve a PDF file to a user from HTML
gem 'image_processing', '~> 1.2'
gem 'poppler'
gem 'active_storage_validations'
gem 'lightbox2-rails'
gem 'rtesseract'
gem 'pdftoimage'

# Utility
gem 'dotenv-rails' # Load environment variables from `.env`
gem 'httparty' # Makes http fun again!
gem 'annotate' # Annotates Rails/ActiveRecord Models
gem "intercom-rails" # This library makes it easier to use the correct javascript tracking code in your rails applications
gem 'chronic_duration' # Simple Ruby natural language parser for elapsed time
gem 'psych', '~> 3.1'

# Authentication
gem 'devise' # Flexible authentication solution for Rails with Warden
gem 'devise_masquerade' # Add ability to login as another user as an admin
gem 'devise-two-factor' # Barebones two-factor authentication with Devise

# Email
gem 'inky-rb', require: 'inky' # Inky is an HTML-based templating language that converts simple HTML into complex, responsive email-ready HTML
gem 'premailer-rails' # Create HTML emails, include a CSS file as you do in a normal HTML document and premailer will inline the included CSS.

# Admin
gem 'activeadmin' # The administration framework for Ruby on Rails
gem 'activeadmin_addons' # Extends ActiveAdmin with helpful addons
gem 'activeadmin-searchable_select'

# Services
gem 'aws-sdk-s3' # Official AWS Ruby gem for Amazon Simple Storage Service (Amazon S3)
gem 'slack-notifier' # Notifications on Slack
gem 'sentry-ruby', '~> 5.5.0'
gem 'sentry-rails', '~> 5.5.0'
gem 'sentry-sidekiq', '~> 5.5.0'
gem 'sentry-delayed_job', '~> 5.5.0'
gem 'mailgun-ruby' # Mailgun's Official Ruby SDK for interacting with the Mailgun API
gem 'stripe' # Ruby library for the Stripe API
gem 'contentful' # API for Contentful headless CMS
gem 'rich_text_renderer' # Contentful Rich Text renderer
gem "pipedrive-connect", github: "getonbrd/pipedrive-connect"

# Production
group :production do 
  gem 'dalli' # MemCachier support for caching
  gem 'wkhtmltopdf-heroku', '2.12.6.1.pre.jammy' # Experimental support for Heroku Stack-22 (Ubuntu 22.04 LTS Jammy)
end

# Development & Test
group :development, :test do
  # Utility
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw] # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'guard' # Easily handle events on file system modifications
  gem 'guard-rspec' # Automatically run your specs
  gem 'wkhtmltopdf-binary' # Provides binaries for WKHTMLTOPDF project in an easily accessible package.

  # Testing
  gem 'rspec-rails', '~> 6.0.0.rc1' # Behaviour Driven Development for Ruby
  gem 'factory_bot_rails' # Fixtures. A library for setting up Ruby objects as test data
  gem 'faker' # Fake data generator
  gem 'shoulda-matchers'  # Provides  one-liners to test common Rails functionality that, if written by hand, would be much longer, more complex, and error-prone
  gem 'timecop'           # Time traveling and time freezing in specs
end

# Development
group :development do
  gem 'web-console' # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'listen' # Listens to file modifications and notifies you about the changes
  gem 'spring' # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring-watcher-listen' # Spring x Listen
end

# Test
group :test do
  gem 'capybara', '>= 2.15' # Adds support for Capybara system testing and selenium driver
  gem 'selenium-webdriver' # WebDriver is a tool for writing automated tests of websites.
  # gem 'chromedriver-helper' # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'database_cleaner-active_record' # Strategies for cleaning databases. Can be used to ensure a clean state for testing.
  gem 'simplecov', require: false # Coverage reports
  gem 'capybara-select-2' # Select2 Capybara helper
  gem 'stripe-ruby-mock', '~> 3.1.0.rc3', :require => 'stripe_mock'
  gem 'climate_control' # Modify your ENV
  gem 'parallel_tests'
  gem 'rails-controller-testing'
end
