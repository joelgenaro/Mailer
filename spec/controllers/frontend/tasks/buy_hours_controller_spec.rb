require 'rails_helper'

RSpec.describe Frontend::Tasks::BuyHoursController, type: :controller do
  include ControllerHelper
  include AuthHelper

  let(:stripe_helper) { StripeMock.create_test_helper }

  before do 
    http_login
    StripeMock.start

    @user = create(:user, :with_profile, :with_payment_method)
    @subscription = create(:subscription, :with_plan_assistant, user: @user)
    @task = create(:assistant_task, task_list: @user.task_list)
    @valid_params = {
      t: @task.id, # Task
      m: 15, # Minutes
      c: 1000, # Cost
      ct: "2021-08-04T03:00:13+09:00", # Created At
      d: "1ace71e342a8bf9ce1b706839105ba99837fa9a517d59a2b285d5bab5d6607bd" # Digest
    }
  end

  after do
    StripeMock.stop
  end

  context "GET #buy_additional_time" do
    it "requires authentication" do
      get :buy_additional_time
      expect_redirect_to_login_page
    end

    it "it is successful" do
      expect(Assistant::BuyAdditionalTime).to receive(:validate_link_digest).with({
        task: @task,
        minutes: 15,
        cost: 1000,
        created_at: "2021-08-04T03:00:13+09:00",
        digest: "1ace71e342a8bf9ce1b706839105ba99837fa9a517d59a2b285d5bab5d6607bd"
      }).and_return([true, nil])
      sign_in @user
      get :buy_additional_time, params: @valid_params
      expect(response.status).to eq(200)
    end

    it '404s if no task' do 
      expect{
        sign_in @user
        get :buy_additional_time, params: {}
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'redirects if missing param' do 
      sign_in @user
      [:m, :c, :ct, :d].each do |param_to_omit|
        get :buy_additional_time, params: @valid_params.except(param_to_omit)
        expect(response.status).to eq(302)
        expect(response.headers['Location']).to eq('http://test.host/app/tasks')
        expect(flash[:error]).to eq('Invalid URL')
        flash[:error] = nil
        expect(flash[:error]).to be_nil
      end
    end

    it 'redirects if invalid link digest' do 
      expect(Assistant::BuyAdditionalTime).to receive(:validate_link_digest).and_return([false, 'Invalid link, has expired or something'])
      sign_in @user
      get :buy_additional_time, params: @valid_params
      expect(response.status).to eq(302)
      expect(response.headers['Location']).to eq('http://test.host/app/tasks')
      expect(flash[:error]).to eq('Invalid link, has expired or something')
    end
  end

  context "POST #buy_additional_time_perform" do
    it "requires authentication" do
      post :buy_additional_time_perform
      expect_redirect_to_login_page
    end

    it "it is successful" do
      expect(Assistant::BuyAdditionalTime).to receive(:validate_link_digest).with({
        task: @task,
        minutes: 15,
        cost: 1000,
        created_at: "2021-08-04T03:00:13+09:00",
        digest: "1ace71e342a8bf9ce1b706839105ba99837fa9a517d59a2b285d5bab5d6607bd"
      }).and_return([true, nil])

      expect(SlackNotificationJob).to receive(:perform_later).with(
        "*Extra Time Purchased:* #{@user.email} has purchased 15 minutes (via additional time email). [View user](http://test.host/boxm293/admin/users/#{@user.id}). "
      )

      expect(@user.payments.count).to eq(0)
      expect(@user.time_allocations.count).to eq(0)

      sign_in @user
      post :buy_additional_time_perform, params: @valid_params
      expect(response.status).to eq(302)
      expect(response.headers['Location']).to eq('http://test.host/app/tasks')
      expect(flash[:notice]).to eq('Thank you for purchasing extra time.')

      # Created payment
      expect(@user.payments.count).to eq(1)
      payment = @user.payments.last
      expect(payment.description).to eq("Purchase 15 minutes")
      expect(payment.total_amount).to eq(15000) # 15 * 1000
      expect(payment.payment_method).to eq(@user.default_payment_method)
      expect(payment.state).to eq('succeeded')
      expect(payment.stripe_payment_intent_id).to start_with('test_pi_')

      # Created time allocation
      expect(@user.time_allocations.count).to eq(1)
      time_allocation = @user.time_allocations.last
      expect(time_allocation.minutes).to eq(15)
      expect(time_allocation.valid_to).to be_within(1.minute).of(DateTime.now + 30.days)
      expect(time_allocation.valid_from).to be_within(1.minute).of(DateTime.now)

      # Linked payment to time allocation
      expect(payment.source).to eq(time_allocation)
    end

    it '404s if no task' do 
      expect{
        sign_in @user
        post :buy_additional_time_perform, params: {}
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'redirects if missing param' do 
      sign_in @user
      [:m, :c, :ct, :d].each do |param_to_omit|
        post :buy_additional_time_perform, params: @valid_params.except(param_to_omit)
        expect(response.status).to eq(302)
        expect(response.headers['Location']).to eq('http://test.host/app/tasks')
        expect(flash[:error]).to eq('Invalid URL')
        flash[:error] = nil
        expect(flash[:error]).to be_nil
      end
    end

    it 'redirects if invalid link digest' do 
      expect(Assistant::BuyAdditionalTime).to receive(:validate_link_digest).and_return([false, 'Invalid link, has expired or something'])
      sign_in @user
      post :buy_additional_time_perform, params: @valid_params
      expect(response.status).to eq(302)
      expect(response.headers['Location']).to eq('http://test.host/app/tasks')
      expect(flash[:error]).to eq('Invalid link, has expired or something')
    end

    it 'shows error if unable to charge payment' do 
      # No payment method will cause the error
      user = create(:user, :with_profile) 
      subscription = create(:subscription, :with_plan_assistant, user: user)
      task = create(:assistant_task, task_list: user.task_list)

      expect(Assistant::BuyAdditionalTime).to receive(:validate_link_digest).and_return([true, nil])
      expect(SlackNotificationJob).to_not receive(:perform_later)

      expect(user.payments.count).to eq(0)
      expect(user.time_allocations.count).to eq(0)

      sign_in user
      post :buy_additional_time_perform, params: {
        t: task.id, # Task
        m: 15, # Minutes
        c: 1000, # Cost
        ct: "2021-08-04T03:00:13+09:00", # Created At
        d: "1ace71e342a8bf9ce1b7XYZZYZYZY7fa9a517d59a2b285d5bab5d6607bd" # Digest
      }
      expect(response.status).to eq(302)
      expect(response.headers['Location']).to eq("http://test.host/app/tasks/buy_additional_time?ct=2021-08-04T03%3A00%3A13%2B09%3A00&d=1ace71e342a8bf9ce1b7XYZZYZYZY7fa9a517d59a2b285d5bab5d6607bd&t=#{task.id}")
      expect(flash[:error]).to eq('Error occurred attempting to purchase time')

      user.reload
      expect(user.payments.count).to eq(0)
      expect(user.time_allocations.count).to eq(0)
    end

    it 'shows error if unable to charge payment due to Stripe' do 
      user = create(:user, :with_profile, :with_payment_method)
      subscription = create(:subscription, :with_plan_assistant, user: user)
      task = create(:assistant_task, task_list: user.task_list)

      expect(Assistant::BuyAdditionalTime).to receive(:validate_link_digest).and_return([true, nil])
      stripe_card_error = Stripe::CardError.new(
        'Card was declined for some reason',
        'param', 
        json_body: {'error' => { 'payment_intent' => { 'id' => 'stub_pi_123' } }}
      )
      expect(Stripe::PaymentIntent).to receive(:create).and_raise(stripe_card_error)
      expect(SlackNotificationJob).to_not receive(:perform_later)

      expect(user.payments.count).to eq(0)
      expect(user.time_allocations.count).to eq(0)

      sign_in user
      post :buy_additional_time_perform, params: {
        t: task.id, # Task
        m: 15, # Minutes
        c: 1000, # Cost
        ct: "2021-08-04T03:00:13+09:00", # Created At
        d: "1ace71e342a8bf9ce1b7XYZZYZYZY7fa9a517d59a2b285d5bab5d6607bd" # Digest
      }
      expect(response.status).to eq(302)
      expect(response.headers['Location']).to eq("http://test.host/app/tasks/buy_additional_time?ct=2021-08-04T03%3A00%3A13%2B09%3A00&d=1ace71e342a8bf9ce1b7XYZZYZYZY7fa9a517d59a2b285d5bab5d6607bd&t=#{task.id}")
      expect(flash[:error]).to eq('Card was declined for some reason')

      user.reload
      expect(user.payments.count).to eq(0)
      expect(user.time_allocations.count).to eq(0)
    end
  end
end