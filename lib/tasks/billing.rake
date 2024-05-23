# Billing related tasks
namespace :billing do

  # Daily Stripe Sync
  # Goes through our subscriptions and updates them based on their 
  # Stripe subscription, ensuring they're in sync.
  # In future, could ignore any with a 'canceled' status, as they'll never change
  task daily_stripe_sync: :environment do
    subscriptions = Subscription.where.not(stripe_subscription_id: nil).or(Subscription.where.not(legacy_stripe_account: true))
    subscriptions.each do |subscription|
      subscription.update_from_stripe_subscription!
    end
  end
  
end