require 'rails_helper'

RSpec.describe Bebop::Mutations::SendAdditionalTimeEmailMutation, type: :request do
  include BebopGraphQLHelper

  before(:all) do 
    @admin_user = create(:admin_user)
    @task = create(:assistant_task)
    @minutes = 15
    @cost = 1000
    @message = 'In order to complete your task {{task}}, you require an additional {{time}} for {{cost}}. Please purchase the additional time in order to complete your task and avoid delays.'

    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  after(:all) do
    ActionMailer::Base.deliveries.clear
  end

  it 'authenticates admin' do
    ensure_admin_user_authenticated(query(@task.id, 4, @cost, @message))
  end

  it 'sends the email' do 
    expect(ActionMailer::Base.deliveries.count).to eq(0)

    expect(Assistant::BuyAdditionalTime).to receive(:generate_link_digest).with({
      task: @task, minutes: 15, cost: 1000
    }).and_return(
      ["2021-08-04T03:00:13+09:00", "1ace71e342a8bf9ce1b706839105ba99837fa9a517d59a2b285d5bab5d6607bd"]
    ).exactly(1).times

    expect(Assistant::TaskMailer).to receive(:buy_additional_time_email).with(
      @task.id, 15, 1000, "2021-08-04T03:00:13+09:00", "1ace71e342a8bf9ce1b706839105ba99837fa9a517d59a2b285d5bab5d6607bd", @message
    ).and_call_original.exactly(1).times

    authorized_request(@admin_user, query(@task.id, @minutes, @cost, @message)) 
    data = response.parsed_body['data']['sendAdditionalTimeEmail']
    expect(data['success']).to eq(true)

    # Includes the rendered message and the link with digest and required params
    expect(ActionMailer::Base.deliveries.last.to_s).to include(
      "In order to complete your task Visa research, you require=0D\nan additional 15 minutes for =C2=A515,000. Please purchase the=0D\nadditional time in order to complete your task and avoid delays."
    )
    expect(ActionMailer::Base.deliveries.last.to_s).to include(
      "href=3D\"http://localhost:3000/app/tasks/buy_additional_t=\nime?c=3D1000&amp;ct=3D2021-08-04T03%3A00%3A13%2B09%3A00&amp;d=3D1ace71e34=\n2a8bf9ce1b706839105ba99837fa9a517d59a2b285d5bab5d6607bd&amp;m=3D15&amp;t=3D=\n#{@task.id}\""
    )
  end

  it 'returns error if invalid task id' do 
    authorized_request(@admin_user, query(999999, @minutes, @cost, @message)) 
    expect_not_found_error(response.parsed_body)
  end

  it 'returns error if not enough time required' do 
    authorized_request(@admin_user, query(@task.id, 4, @cost, @message)) 
    data = response.parsed_body['data']['sendAdditionalTimeEmail']
    expect(data['success']).to eq(false)
    expect(data['errorMessage']).to eq('Minimum 5 of additional minutes required')
  end

  it 'returns error if not enough cost per minute' do 
    authorized_request(@admin_user, query(@task.id, @minutes, 99, @message)) 
    data = response.parsed_body['data']['sendAdditionalTimeEmail']
    expect(data['success']).to eq(false)
    expect(data['errorMessage']).to eq('Minimum of ¥100 per minute')
  end

  it 'returns error if not including all message variables' do 
    [
      "",
      "{{time}}",
      "{{time}} {{cost}}",
      "{{time}} {{task}} ",
      "{{time}} {{task}} {{other}}",
      "{time} {{task}} {{cost}} malformed",
    ].each do |message|
      authorized_request(@admin_user, query(@task.id, @minutes, @cost, message)) 
      data = response.parsed_body['data']['sendAdditionalTimeEmail']
      expect(data['success']).to eq(false)
      expect(data['errorMessage']).to eq('Message must include at least one of each variable: task, time, cost')
    end
  end

  def query(assistant_task_id, time_required, cost_per_minute, message)
    <<~GQL
      mutation {
        sendAdditionalTimeEmail(input: { 
          assistantTaskId: "#{assistant_task_id}",
          timeRequired: #{time_required},
          costPerMinute: #{cost_per_minute},
          message: "#{message}"
        }){
          success
          errorMessage
        }
      }
    GQL
  end
end