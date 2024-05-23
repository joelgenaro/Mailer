require 'rails_helper'
include AuthHelper
RSpec.describe RegisterController, type: :controller do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before { 
    http_login
    Growth::Referrer.where(code: 'cic').destroy_all # As codes are unique, start fresh
    @growth_referrer_cic = create(:growth_referrer, :with_code_cic)
    StripeMock.start 
  }
  after { StripeMock.stop }

  context 'POST #index' do 
    it 'signs up user normally' do 
      email = "foo@#{SecureRandom.hex(3)}.jp"
      expect(User.find_by(email: email)).to be_nil

      expect_any_instance_of(RegisterController).to receive(:before_action_ensure_terms_agreed).and_call_original
      expect_any_instance_of(RegisterController).to receive(:before_action_set_growth_referrer).and_call_original
      expect_any_instance_of(RegisterController).to receive(:user_attributes).and_call_original
      expect_any_instance_of(RegisterController).to receive(:build_stripe_session_discounts).and_call_original
      
      post :index, params: { 
        user: {
          email: email,
          password: 'password',
        },
        subscription_type: 'assistant',
        subscription_name: 'assistant_individual_starter',
        format: :json
      }

      expect(response.status).to eq(200)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body).to match({ "stripe_session_id" => start_with('test_cs') })
      expect(parsed_body.keys).to eq(['stripe_session_id'])

      new_user = User.find_by(email: email)
      expect(new_user.growth_referrer).to be_nil

      stripe_checkout_session = Stripe::Checkout::Session.retrieve(parsed_body['stripe_session_id'])
      expect(stripe_checkout_session.mode).to eq('subscription')
      expect(stripe_checkout_session.payment_method_types).to eq(['card'])
      expect(stripe_checkout_session.success_url).to eq("http://test.host/checkout/success?session_id={CHECKOUT_SESSION_ID}")
      expect(stripe_checkout_session.cancel_url).to eq("http://test.host/checkout/cancel")
      expect(stripe_checkout_session.customer_email).to eq(email)
      expect(stripe_checkout_session.metadata.to_h).to eq({ "subscription_name": "assistant_individual_starter", "subscription_type": "assistant" })
      expect(stripe_checkout_session.allow_promotion_codes).to eq(false)
      #expect(stripe_checkout_session.discounts).to be_nil
    end

    context 'signs up user with referrer and discount' do 
      it 'cic' do
        cookies['tkm_referrer'] = 'cic'

        email = "foo@#{SecureRandom.hex(3)}.jp"
        post :index, params: { 
          user: {
            email: email,
            password: 'password',
          },
          subscription_type: 'mail',
          subscription_name: 'mail_pro',
          format: :json
        }

        expect(response.status).to eq(200)
        parsed_body = JSON.parse(response.body)
        expect(parsed_body).to match({ "stripe_session_id" => start_with('test_cs') })
        expect(parsed_body.keys).to eq(['stripe_session_id'])
  
        new_user = User.find_by(email: email)
        expect(new_user.growth_referrer).to eq(@growth_referrer_cic)

        stripe_checkout_session = Stripe::Checkout::Session.retrieve(parsed_body['stripe_session_id'])
        expect(stripe_checkout_session.mode).to eq('subscription')
        expect(stripe_checkout_session.payment_method_types).to eq(['card'])
        expect(stripe_checkout_session.success_url).to eq("http://test.host/checkout/success?session_id={CHECKOUT_SESSION_ID}")
        expect(stripe_checkout_session.cancel_url).to eq("http://test.host/checkout/cancel")
        expect(stripe_checkout_session.customer_email).to eq(email)
        expect(stripe_checkout_session.metadata.to_h).to eq({ "subscription_name": "mail_pro", "subscription_type": "mail" })
        expect(stripe_checkout_session.allow_promotion_codes).to be_nil
        expect(stripe_checkout_session.discounts.as_json).to eq([ { "coupon" => @growth_referrer_cic.parameters['lifetime_stripe_coupon_id'] } ])
      end
    end
  end

  context 'before_action_set_growth_referrer' do 
    it 'cic' do 
      controller.send(:cookies)[:tkm_referrer] = 'cic'
      expect(controller.send(:before_action_set_growth_referrer)).to eq(@growth_referrer_cic)
    end

    it 'ignores no cookie and invalid code' do 
      # No cookie 
      expect(controller.send(:cookies)[:tkm_referrer]).to be_nil
      expect(controller.send(:before_action_set_growth_referrer)).to be_nil

      # Invalid code
      controller.send(:cookies)[:tkm_referrer] = 'bad'
      expect(controller.send(:before_action_set_growth_referrer)).to be_nil
    end
  end

  it 'build_stripe_session_discounts' do 
    # If no growth referrer
    expect(controller.instance_variable_get(:@growth_referrer)).to be_nil
    expect(controller.send(:build_stripe_session_discounts)).to be_nil

    # If not CIC
    controller.instance_variable_set(:@growth_referrer, create(:growth_referrer, code: 'alt'))
    expect(controller.send(:build_stripe_session_discounts)).to be_nil

    # Before 20 conversions (lifetime coupon)
    expect(@growth_referrer_cic.conversions).to eq(0)
    controller.instance_variable_set(:@growth_referrer, @growth_referrer_cic)
    expect(controller.send(:build_stripe_session_discounts)).to eq(
      [ { coupon: "wDxLIFETIME" } ]
    )
    @growth_referrer_cic.update(conversions: 19)
    expect(controller.send(:build_stripe_session_discounts)).to eq(
      [ { coupon: "wDxLIFETIME" } ]
    )

    # After 20 conversions (month coupon)
    @growth_referrer_cic.update(conversions: 21)
    expect(controller.send(:build_stripe_session_discounts)).to eq(
      [ { coupon:  @growth_referrer_cic.parameters['month_stripe_coupon_id'] } ]
    )
  end
end