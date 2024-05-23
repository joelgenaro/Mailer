require 'rails_helper'

RSpec.describe Assistant::Services::AdditionalTimePurchasable, type: :service do

  let(:stripe_helper) { StripeMock.create_test_helper }

  before do 
    StripeMock.start
  end

  after do
    StripeMock.stop
  end

  context 'call' do
    context 'purchases minutes' do 
      it 'partial: 2 of 3 hours available' do 
        user = create(:user, :with_payment_method)
        subscription = create(:subscription, :with_plan_assistant, user: user)

        expect(user.payments.count).to eq(0)
        expect(user.time_allocations.count).to eq(0)

        expect(Assistant::Services::AdditionalTimePurchasable).to receive(:call).with(user: user).exactly(1).times.and_call_original
        expect(Assistant::Services::PurchaseAdditionalTime).to receive(:purchase_amount).with(minutes: 120).exactly(1).times.and_call_original

        # Plan references:
        # assistant_individual_executive = 3 hours additional (180 minutes)

        # Current subscription period is 2021-09-02 to 2021-10-02,
        # we'll say today is 2021-9-15 (in the middle of period)
        Timecop.freeze('2021-9-15 15:55:00') do  
          payment = Assistant::Services::PurchaseAdditionalTime.call(user: user, minutes: 120)

          expect(user.payments.count).to eq(1)
          expect(user.payments.last).to eq(payment)
          expect(payment.user).to eq(user)
          expect(payment.description).to eq("Purchase 120 additional minutes",)
          expect(payment.total.cents).to eq(14000)
          expect(payment.payment_method).to eq(user.default_payment_method)
          expect(payment.source).to eq(user.time_allocations.last)

          expect(user.time_allocations.count).to eq(1)
          expect(user.time_allocations.last.minutes).to eq(120)
          expect(user.time_allocations.last.valid_from).to eq('2021-9-15 15:55:00')
          expect(user.time_allocations.last.valid_to).to eq('2021-10-15 15:55:00')
          expect(user.time_allocations.last.source).to eq('additional_time_purchase')
        end
      end

      it 'total: full 3 hours available' do 
        user = create(:user, :with_payment_method)
        subscription = create(:subscription, :with_plan_assistant, user: user)

        expect(user.payments.count).to eq(0)
        expect(user.time_allocations.count).to eq(0)

        expect(Assistant::Services::AdditionalTimePurchasable).to receive(:call).with(user: user).exactly(1).times.and_call_original
        expect(Assistant::Services::PurchaseAdditionalTime).to receive(:purchase_amount).with(minutes: 180).exactly(1).times.and_call_original

        # Plan references:
        # assistant_individual_executive = 3 hours additional (180 minutes)

        # Current subscription period is 2021-09-02 to 2021-10-02,
        # we'll say today is 2021-9-15 (in the middle of period)
        Timecop.freeze('2021-9-15 15:55:00') do  
          payment = Assistant::Services::PurchaseAdditionalTime.call(user: user, minutes: 180)

          expect(user.payments.count).to eq(1)
          expect(user.payments.last).to eq(payment)
          expect(payment.user).to eq(user)
          expect(payment.description).to eq("Purchase 180 additional minutes",)
          expect(payment.total.cents).to eq(21000)
          expect(payment.payment_method).to eq(user.default_payment_method)
          expect(payment.source).to eq(user.time_allocations.last)

          expect(user.time_allocations.count).to eq(1)
          expect(user.time_allocations.last.minutes).to eq(180)
          expect(user.time_allocations.last.valid_from).to eq('2021-9-15 15:55:00')
          expect(user.time_allocations.last.valid_to).to eq('2021-10-15 15:55:00')
          expect(user.time_allocations.last.source).to eq('additional_time_purchase')
        end
      end

      it 'end to end'do 
        user = create(:user, :with_payment_method)
        subscription = create(:subscription, :with_plan_assistant, user: user)

        expect(user.payments.count).to eq(0)
        expect(user.time_allocations.count).to eq(0)

        # Plan references:
        # assistant_individual_executive = 3 hours additional (180 minutes)

        # Current subscription period is 2021-09-02 to 2021-10-02,
        # we'll say today is 2021-9-15 (in the middle of period)
        Timecop.freeze('2021-9-15 15:55:00') do  
          # Purchase 2 hours
          expect(Assistant::Services::AdditionalTimePurchasable.call(user: user)).to eq(180)
          payment = Assistant::Services::PurchaseAdditionalTime.call(user: user, minutes: 120)
          expect(user.payments.count).to eq(1)
          expect(user.time_allocations.count).to eq(1)
          expect(user.time_allocations.last.minutes).to eq(120)

          # Try purchase 2 hours, not allowed
          expect(Assistant::Services::AdditionalTimePurchasable.call(user: user)).to eq(60)
          expect {
            Assistant::Services::PurchaseAdditionalTime.call(user: user, minutes: 120)
          }.to raise_error do |error| 
            expect(error.code).to eq('assistant.services.PurchaseAdditionalTime')
            expect(error.message).to eq('Requested time to purchase exceeds current available time to purchase')
          end
          user.reload
          expect(user.payments.count).to eq(1)
          expect(user.time_allocations.count).to eq(1)
          expect(user.time_allocations.last.minutes).to eq(120)

          # Purchase 1 hour
          expect(Assistant::Services::AdditionalTimePurchasable.call(user: user)).to eq(60)
          payment = Assistant::Services::PurchaseAdditionalTime.call(user: user, minutes: 60)
          expect(user.payments.count).to eq(2)
          expect(user.time_allocations.count).to eq(2)
          expect(user.time_allocations.last.minutes).to eq(60)
          
          # Try purchase 1 hour, not allowed
          expect(Assistant::Services::AdditionalTimePurchasable.call(user: user)).to eq(0)
          expect {
            Assistant::Services::PurchaseAdditionalTime.call(user: user, minutes: 60)
          }.to raise_error do |error| 
            expect(error.code).to eq('assistant.services.PurchaseAdditionalTime')
            expect(error.message).to eq('Requested time to purchase exceeds current available time to purchase')
          end
          user.reload
          expect(user.payments.count).to eq(2)
          expect(user.time_allocations.count).to eq(2)
          expect(user.time_allocations.last.minutes).to eq(60)
        end
      end
    end

    it 'returns error if no assistant subscription found for user' do 
      user = create(:user)
      expect(user.subscriptions.count).to eq(0)
      expect(user.payments.count).to eq(0)

      # No subscriptions
      expect { 
        Assistant::Services::PurchaseAdditionalTime.call(user: user, minutes: 60)
      }.to raise_error do |error| 
        expect(error.code).to eq('assistant.services.PurchaseAdditionalTime')
        expect(error.message).to eq('No assistant subscription found')
      end
      expect(user.payments.count).to eq(0)

      # No Assistant subscription
      create(:subscription, :with_plan_mail, user: user)
      expect(user.subscriptions.count).to eq(1)
      expect { 
        Assistant::Services::PurchaseAdditionalTime.call(user: user, minutes: 60)
      }.to raise_error do |error| 
        expect(error.code).to eq('assistant.services.PurchaseAdditionalTime')
        expect(error.message).to eq('No assistant subscription found')
      end
      user.reload
      expect(user.payments.count).to eq(0)
    end

    it 'returns error if minutes exceed available purchasable minutes' do 
      user = create(:user)
      subscription = create(:subscription, :with_plan_assistant, user: user)
      expect(user.payments.count).to eq(0)
      expect(user.time_allocations.count).to eq(0)

      # Plan references:
      # assistant_individual_executive = 3 hours additional (180 minutes)

      # Current subscription period is 2021-09-02 to 2021-10-02,
      # we'll say today is 2021-9-15 (in the middle of period)
      Timecop.freeze('2021-9-15 15:55:00') do  
        # Called 2 times in this test itself
        expect(Assistant::Services::AdditionalTimePurchasable).to receive(:call).with(user: user).exactly(4).times.and_call_original

        # Partial exceed (1 hour remains, but ask for 2)
        create(:assistant_time_allocation, user: user, source: :additional_time_purchase, minutes: 2 * 60, valid_from: Time.now, valid_to: Time.now + 30.days)
        expect(Assistant::Services::AdditionalTimePurchasable.call(user: user)).to eq(60)
        expect { 
          Assistant::Services::PurchaseAdditionalTime.call(user: user, minutes: 120)
        }.to raise_error do |error| 
          expect(error.code).to eq('assistant.services.PurchaseAdditionalTime')
          expect(error.message).to eq('Requested time to purchase exceeds current available time to purchase')
        end
        user.reload
        expect(user.payments.count).to eq(0)
        expect(user.time_allocations.count).to eq(1)

        # Total exceed
        create(:assistant_time_allocation, user: user, source: :additional_time_purchase, minutes: 1 * 60, valid_from: Time.now, valid_to: Time.now + 30.days)
        expect(Assistant::Services::AdditionalTimePurchasable.call(user: user)).to eq(0)
        expect { 
          Assistant::Services::PurchaseAdditionalTime.call(user: user, minutes: 60)
        }.to raise_error do |error| 
          expect(error.code).to eq('assistant.services.PurchaseAdditionalTime')
          expect(error.message).to eq('Requested time to purchase exceeds current available time to purchase')
        end
        user.reload
        expect(user.payments.count).to eq(0)
        expect(user.time_allocations.count).to eq(2)
      end
    end

    it 'returns error if Stripe card error' do 
      user = create(:user, :with_payment_method)
      subscription = create(:subscription, :with_plan_assistant, user: user)
      expect(user.payments.count).to eq(0)
      expect(user.time_allocations.count).to eq(0)

      expect(Assistant::Services::AdditionalTimePurchasable).to receive(:call).with(user: user).exactly(1).times.and_call_original
      expect(Assistant::Services::PurchaseAdditionalTime).to receive(:purchase_amount).with(minutes: 120).exactly(1).times.and_call_original

      stripe_card_error = Stripe::CardError.new(
        'Card was declined for some reason',
        'param', 
        json_body: {'error' => { 'payment_intent' => { 'id' => 'stub_pi_123' } }}
      )
      expect(Stripe::PaymentIntent).to receive(:create).and_raise(stripe_card_error)

      # Plan references:
      # assistant_individual_executive = 3 hours additional (180 minutes)

      # Current subscription period is 2021-09-02 to 2021-10-02,
      # we'll say today is 2021-9-15 (in the middle of period)
      Timecop.freeze('2021-9-15 15:55:00') do  
        expect { 
          Assistant::Services::PurchaseAdditionalTime.call(user: user, minutes: 120)
        }.to raise_error do |error| 
          expect(error.code).to eq('assistant.services.PurchaseAdditionalTime')
          expect(error.message).to eq('Card was declined for some reason')
        end
        user.reload
        expect(user.payments.count).to eq(0)
        expect(user.time_allocations.count).to eq(0)
      end
    end
  end

  it 'purchase_amount' do 
    expect(Assistant::Services::PurchaseAdditionalTime.purchase_amount(minutes: 60)).to eq(7000)
    expect(Assistant::Services::PurchaseAdditionalTime.purchase_amount(minutes: 120)).to eq(14000)
    expect(Assistant::Services::PurchaseAdditionalTime.purchase_amount(minutes: 180)).to eq(21000)
    expect(Assistant::Services::PurchaseAdditionalTime.purchase_amount(minutes: 420)).to eq(49000)
  end
end