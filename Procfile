# Web Processes
web: bundle exec puma -p $PORT -C ./config/puma.rb

# Worker Processes
worker: bundle exec sidekiq -C config/sidekiq.yml

release: rake db:migrate
