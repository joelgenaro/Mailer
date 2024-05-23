require 'us_domain'
Rails.application.routes.draw do
  constraints(UsDomain) do
    get '/', to: 'landing#index', as: :root_us
    post 'submit', to: 'landing#submit_email', as: :submit_email
  end
  # Root
  root 'marketing/pages#mail'
  get '/', to: 'marketing/pages#mail', as: :root_en
  get '/ja', to: 'marketing/pages#mail', as: :root_ja

  # redirect ja/pricing/mail to ja#plans
  get "/ja/pricing/mail", to: redirect("/ja#plans", status: 301)

  # Sitemap
  get '/sitemaps/sitemap.xml.gz', to: redirect(ENV.fetch('SITEMAP_S3_URL')), as: :sitemap

  # Registration & Stripe Checkout
  post 'register', to: 'register#index', as: :register
  post 'subscribe', to: 'register#onboarding_subscribe', as: :onboarding_subscribe
  post 'checkout', to: 'checkout#index', as: :checkout
  get 'checkout/success', to: 'checkout/success#index', as: :checkout_success
  get 'checkout/cancel', to: 'checkout/cancel#index', as: :checkout_cancel

  # Errors
  get '404', to: "errors#not_found"
  get '422', to: "errors#unacceptable"
  get '500', to: "errors#internal_error"

  # Marketing
  localized do
    scope '/', module: :marketing, as: :marketing do
      # Pages
      get 'mail', to: 'pages#mail', as: :mail
      get 'assistant', to: 'pages#assistant', as: :assistant
      get 'faq', to: 'pages#faq', as: :faq
      get 'pricing(/:page)', to: 'pages#pricing', as: :pricing
      get 'terms', to: 'pages#terms', as: :terms_of_service
      get 'privacy', to: 'pages#privacy', as: :privacy_policy
      get 'about', to: 'pages#about', as: :about

      # Request Consultation
      get 'consultation', to: 'consultation#index', as: :request_consultation
      post 'consultation', to: 'consultation#submit', as: :submit_request_consultation
      
      # Blog
      get '/blog', to: 'blog#index', as: :blog
      get '/blog/:slug', to: 'blog#show', as: :blog_post
      get '/blog/author/:slug', to: 'blog#show_author', as: :blog_author
      get '/blog/category/:slug', to: 'blog#show_category', as: :blog_category

      # Service Directory
      get '/service-directory', to: 'service_directory#index', as: :service_directory
      get '/service-directory/category/:category_slug', to: 'service_directory#show_category_listings', as: :show_category_listings
      get '/service-directory/listing/:slug', to: 'service_directory#show_service_listing', as: :show_service_listing
    
      # Growth
      get '/referrer/:code', to: 'growth#referrer', as: :growth_referrer

      # Redirects
      get '/assistant', to: redirect('/')
      get '/receptionist', to: redirect('/')

    end
  end

  localized do
    post 'pricing(/:page)', to: 'register#new', as: :new_register
  end

  # Frontend
  scope '/app', module: :frontend do
    # Home
    get '/', to: 'home#index', as: :app

    # Mail
    resources :mails, only: %i(index show update edit)
    get 'mails/:id/view_mail', to: 'mails#view_mail', as: :view_mail
    patch 'mails/:id/open_mail', to: 'mails/open_mail#index', as: :open_mail
    
    # Mail - Archiving
    patch 'mails/:id/archive_mail', to: 'mails/postal_mail#archive', as: :archive_mail
    patch 'mails/:id/unarchive_mail', to: 'mails/postal_mail#unarchive', as: :unarchive_mail
    
    # Mail - Generating
    get 'mails/:id/generate_pdf', to: 'mails/pdf_generator#generate_pdf'
    
    # Mail - Deleting on customer side
    patch 'mails/:id/delete_mail', to: 'mails/postal_mail#delete', as: :delete_mail
    
    # Mail - Shred request
    patch 'mails/:id/shred', to: 'mails/postal_mail#shred', as: :shred_mail

    # Mail - Forward request
    get 'mails/:id/forward_mail', to: 'mails/postal_mail#forward_form', as: :forward_mail
    patch 'mails/:id/forward_request', to: 'mails/postal_mail#forward_request', as: :forward_mail_request

    # Mail - Tagging
    get 'mails/:id/tags', to: 'mails/postal_mail#tag_modal', as: :tag_modal
    post 'mails/:id/tag', to: 'mails/postal_mail#tag', as: :tag_mail
    patch 'mails/:id/tag', to: 'mails/postal_mail#remove_tag', as: :remove_tag

    # Mail - Foldering
    get 'mails/:id/folders', to: 'mails/postal_mail#move_folder_modal', as: :move_folder_modal
    get 'mails/:id/folder', to: 'mails/postal_mail#folder', as: :folder_mail
    patch 'mails/:id/folder', to: 'mails/postal_mail#remove_from_folder', as: :remove_folder_mail
    
    # Mail - Email forward
    get 'mails/:id/forward', to: 'mails/postal_mail#email_forward_form', as: :email_forward_form
    patch 'mails/:id/forward', to: 'mails/postal_mail#email_forward', as: :email_forward

    # Mail - Pay bill
    get 'mails/:id/pay_bill', to: 'mails#pay_bill', as: :mail_pay_bill

    # Tag
    resources :tags, only: %i(index create update destroy edit)
    get 'tags/new', to: 'tags#new', as: :tag_form
    # Folder
    resources :folders, only: %i(index create update destroy edit)
    get 'folders/new', to: 'folders#new', as: :folder_form

    # Tasks
    resources :tasks, only: %i(index create update destroy edit)
    get 'tasks/view', to: 'tasks#view', as: :view_task
    post 'tasks/mark_as_complete', to: 'tasks#mark_as_complete', as: :task_mark_as_complete
    get 'tasks/time_usage', to: 'tasks/time_usage#index', as: :time_usage
    get 'tasks/buy_additional_time', to: 'tasks/buy_hours#buy_additional_time', as: :buy_additional_time
    post 'tasks/buy_additional_time', to: 'tasks/buy_hours#buy_additional_time_perform', as: :buy_additional_time_perform
    post 'tasks/pay_bill', to: 'tasks#pay_bill', as: :task_pay_bill
    # Receptionist
    resources :receptionist, only: %i(index)

    # Transactions
    resources :transactions, only: %i(index show)

    # Bills
    post 'bills/:id', to: 'bills#index', as: :bill

    # Settings
    get 'settings', to: 'settings#index', as: :settings
    get 'settings/invoices/:year/:month', to: 'settings#monthly_invoices'
    get 'settings/cancel_account', to: 'settings#cancel_account', as: :cancel_account
    get 'settings/billing', to: 'settings#billing', as: :billing_settings
    patch 'settings/update_locale', to: 'settings/update_locale#update', as: :update_locale
    patch 'settings/update_email', to: 'settings/update_email#update', as: :update_email
    patch 'settings/update_password', to: 'settings/update_password#update', as: :update_password
    patch 'settings/update_request_mail', to: 'settings/update_request_mail#update', as: :update_request_mail
    post 'settings/auto_pay/enable', to: 'settings/auto_pay#enable', as: :enable_auto_pay
    post 'settings/auto_pay/disable', to: 'settings/auto_pay#disable', as: :disable_auto_pay
    patch 'settings/auto_pay_limit', to: 'settings/auto_pay_limit#update', as: :update_auto_pay_limit
    patch 'settings/auto_open_mail', to: 'settings/auto_open_mail#update', as: :update_auto_open_mail
    patch 'settings/assistant_preferences', to: 'settings/assistant_preferences#update', as: :update_assistant_preferences
    post 'settings/change_payment_card', to: 'settings/change_payment_card#index', as: :change_payment_card
    get 'settings/change_payment_card/success', to: 'settings/change_payment_card/success#index', as: :change_payment_card_success
    get 'settings/change_payment_card/cancel', to: 'settings/change_payment_card/cancel#index', as: :change_payment_card_cancel
    get 'settings/pause_subscription/:subscription_id', to: 'settings/update_subscription#pause_subscription', as: :pause_subscription
    get 'settings/resume_subscription/:subscription_id', to: 'settings/update_subscription#resume_subscription', as: :resume_subscription
    get 'settings/cancel_subscription/:subscription_id', to: 'settings/update_subscription#cancel_subscription', as: :cancel_subscription
  end

  # Onboarding
  scope '/onboarding', module: :onboarding do
    get '/', to: 'onboarding#index', as: :onboarding
    get 'plan', to: 'plan#index', as: :onboarding_plan
    get 'profile', to: 'profile#index', as: :onboarding_profile
    post 'profile', to: 'profile#create', as: :onboarding_create_profile
    get 'payment_card', to: 'payment_card#index', as: :onboarding_payment_card
    post 'payment_card/session', to: 'payment_card/session#index', as: :onboarding_payment_card_session
    get 'payment_card/success', to: 'payment_card/success#index', as: :onboarding_payment_card_success
    get 'payment_card/cancel', to: 'payment_card/cancel#index', as: :onboarding_payment_card_cancel
  end

  # Subscriptions
  scope '/subscriptions', module: :subscriptions do
    post 'purchase', to: 'subscriptions#buy_subscription', as: :buy_subscriptions
    get '/:type', to: 'subscriptions#index', as: :subscriptions
    post '/:type', to: 'subscriptions#create', as: :create_subscriptions
  end

  # Stripe Webhook
  post '/stripe_webhook/(:event)', to: 'stripe_webhook#index', as: :stripe_webhook

  # Sidekiq Web UI
  require 'sidekiq/web'
  if Rails.env.production?
    Sidekiq::Web.use Rack::Auth::Basic do |username, password|
      ActiveSupport::SecurityUtils.secure_compare(username, ENV.fetch('SIDEKIQ_WEB_USERNAME')) &
        ActiveSupport::SecurityUtils.secure_compare(password, ENV.fetch('SIDEKIQ_WEB_PASSWORD'))
    end
  end
  mount Sidekiq::Web, at: '/sidekiq'

  # GraphQL
  post "/graphql", to: "graphql#execute"

  # redirects for /en
  get '/en', to: redirect('/')
  match "/en/*path" => redirect("/%{path}"), via: [:get, :post]
  # redirects for /jp
  get '/jp', to: redirect('/ja', status: 301)
  match "/jp/*path" => redirect("/ja/%{path}", status: 301), via: [:get, :post]


  # Mailmate US
  #get 'landing', to: 'landing#index', as: :index
end
