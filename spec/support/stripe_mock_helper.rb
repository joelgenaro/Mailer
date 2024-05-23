require 'stripe_mock/request_handlers/subscriptions.rb'

# Helper methods for working with Stripe Mock.
# 
# References:
# - Overview: https://github.com/stripe-ruby-mock/stripe-ruby-mock#test-helpers
# - Subscription Examples: https://github.com/stripe-ruby-mock/stripe-ruby-mock/blob/v3.1.0/spec/shared_stripe_examples/subscription_examples.rb
# - Canceled Subscription Example: https://github.com/stripe-ruby-mock/stripe-ruby-mock/blob/v3.1.0/spec/shared_stripe_examples/subscription_examples.rb#L103
module StripeMockHelper
  # Generates a Stripe Card Token
  def stripe_mock_generate_card_token 
    return stripe_helper.generate_card_token
  end
end

# Monkeypatch StripeMock to allow mocking a past_due subscription status
# Taken from https://github.com/mysociety/alaveteli/commit/400a69d3cbbd0844d71fcd6a3e737e8ec25558df
module StripeMock
  # Helper method to set the status to 'past_due'
  def self.mark_subscription_as_past_due(subscription)
    ::Stripe::Subscription.update(subscription.id, metadata: { marked_past_due: true })
  end

  module RequestHandlers::Subscriptions
    # copies current method and adds a call to our
    # set_custom_status_from_metatdata method to set the status
    # from the stored info in the subscription metatdata when the
    # subscription is retrieved (including calling #refresh)
    def retrieve_subscription(route, method_url, params, headers)
      route =~ method_url

      set_custom_status_from_metadata(subscriptions[$1]) if subscriptions[$1]
      assert_existence :subscription, $1, subscriptions[$1]
    end

    # copies current method and adds a call to our
    # set_custom_status_from_metatdata method to set the status
    # from the stored info in the subscription metatdata when multiple
    # subscriptions are retrieved (including from `Subscription::List`)
    def retrieve_subscriptions(route, method_url, params, headers)
      route =~ method_url

      subscriptions.values.each do |subscription|
        set_custom_status_from_metadata(subscription)
      end

      Data.mock_list_object(subscriptions.values, params)
    end

    private

    def set_custom_status_from_metadata(subscription)
      if subscription[:metadata][:marked_past_due]
        subscription.merge!(status: 'past_due')
      end
    end
  end
end