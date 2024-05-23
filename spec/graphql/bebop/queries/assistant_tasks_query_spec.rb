require 'rails_helper'

RSpec.describe Bebop::Queries::AssistantTasksQuery, type: :request do
  include BebopGraphQLHelper

  before(:all) do 
    @admin_user = create(:admin_user)

    Assistant::Task.destroy_all
    @task_1 = create(:assistant_task, label: 'Pending Task')
    @task_2 = create(:assistant_task, label: 'In Progress Task', state: 'in_progress')
    @task_3 = create(:assistant_task, label: 'Completed Task', state: 'complete')
  end

  it 'authenticates admin' do
    ensure_admin_user_authenticated(query) 
  end

  it 'returns tasks' do 
    authorized_request(@admin_user, query) 
    data = response.parsed_body['data']['assistantTasks']

    expect(data.count).to eq(3)
    expect(data).to contain_exactly(
      {
        "id"=>@task_1.id.to_s,
        "userId"=>@task_1.user.id.to_s,
        "label"=>"Pending Task",
        "state"=>"pending",
      },
      {
        "id"=>@task_2.id.to_s,
        "userId"=>@task_2.user.id.to_s,
        "label"=>"In Progress Task",
        "state"=>"in_progress",
      },
      {
        "id"=>@task_3.id.to_s,
        "userId"=>@task_3.user.id.to_s,
        "label"=>"Completed Task",
        "state"=>"complete",
      }
    )
  end

  context 'filtering' do 
    it 'user_id' do
      authorized_request(@admin_user, query("(userId: \"#{@task_2.user.id}\")")) 
      data = response.parsed_body['data']['assistantTasks']
  
      expect(data.count).to eq(1)
      expect(data).to contain_exactly(
        {
          "id"=>@task_2.id.to_s,
          "userId"=>@task_2.user.id.to_s,
          "label"=>"In Progress Task",
          "state"=>"in_progress",
        }
      )
    end

    it 'stateIn' do 
      authorized_request(@admin_user, query('(stateIn: ["complete", "pending"])')) 
      data = response.parsed_body['data']['assistantTasks']
  
      expect(data.count).to eq(2)
      expect(data).to contain_exactly(
        {
          "id"=>@task_1.id.to_s,
          "userId"=>@task_1.user.id.to_s,
          "label"=>"Pending Task",
          "state"=>"pending",
        },
        {
          "id"=>@task_3.id.to_s,
          "userId"=>@task_3.user.id.to_s,
          "label"=>"Completed Task",
          "state"=>"complete",
        }
      )
    end
  end 

  def query(args = "")
    <<~GQL
      query {
        assistantTasks#{args} {
          id
          userId
          label 
          state
        }
      }
    GQL
  end
end