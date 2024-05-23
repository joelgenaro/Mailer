require 'rails_helper'

RSpec.describe Bebop::Queries::UsersQuery, type: :request do
  include BebopGraphQLHelper

  before(:all) do 
    @admin_user = create(:admin_user)

    User.destroy_all
    @user_1 = create(:user, :with_profile)
    @user_2 = create(:user, :with_profile, email: "fork@alt-coin.com")
    @user_2.profile.update(first_name: "Satoshi", last_name: "Nakamoto")
  end

  it 'authenticates admin' do
    ensure_admin_user_authenticated(query) 
  end

  it 'returns users' do 
    authorized_request(@admin_user, query) 
    data = response.parsed_body['data']['users']

    expect(data.count).to eq(2)
    expect(data).to contain_exactly(
      {
        "id"=>@user_1.id.to_s,
        "email"=>@user_1.email,
        "profile"=> {
          "id"=>@user_1.profile.id.to_s,
          "userId"=>@user_1.id.to_s,
          "firstName"=>"Spike",
          "lastName"=>"Spiegel",
          "displayName"=>"#{@user_1.id} | Spike Spiegel | #{@user_1.email}"
        }
      },
      {
        "id"=>@user_2.id.to_s,
        "email"=>"fork@alt-coin.com",
        "profile"=> {
          "id"=>@user_2.profile.id.to_s,
          "userId"=>@user_2.id.to_s,
          "firstName"=>"Satoshi",
          "lastName"=>"Nakamoto",
          "displayName"=>"#{@user_2.id} | Satoshi Nakamoto | #{@user_2.email}"
        }
      }
    )
  end

  it 'can also return user\'s subscriptions' do 
    # Create a subscription for a user
    user_2_subscription = create(:subscription, :with_plan_assistant, :with_status_active, user: @user_2)

    subscriptions_fields = <<~GQL
      subscriptions {
        id
        userId
        planType
        plan
        status
        stripeSubscriptionId
        billingStartedAt
        billingPeriodStartedAt
        billingPeriodEndsAt
      }
    GQL
    authorized_request(@admin_user, query("", subscriptions_fields)) 
    data = response.parsed_body['data']['users']

    expect(data.count).to eq(2)
    expect(data).to contain_exactly(
      {
        "id"=>@user_1.id.to_s,
        "email"=>@user_1.email,
        "profile"=> {
          "id"=>@user_1.profile.id.to_s,
          "userId"=>@user_1.id.to_s,
          "firstName"=>"Spike",
          "lastName"=>"Spiegel",
          "displayName"=>"#{@user_1.id} | Spike Spiegel | #{@user_1.email}"
        },
        "subscriptions"=>[]
      },
      {
        "id"=>@user_2.id.to_s,
        "email"=>"fork@alt-coin.com",
        "profile"=> {
          "id"=>@user_2.profile.id.to_s,
          "userId"=>@user_2.id.to_s,
          "firstName"=>"Satoshi",
          "lastName"=>"Nakamoto",
          "displayName"=>"#{@user_2.id} | Satoshi Nakamoto | #{@user_2.email}"
        },
        "subscriptions"=>[
          {
            "id"=>user_2_subscription.id.to_s,
            "userId"=>@user_2.id.to_s,
            "planType"=>"assistant",
            "plan"=>"assistant_individual_executive",
            "status"=>"active",
            "stripeSubscriptionId"=>user_2_subscription.stripe_subscription_id,
            "billingStartedAt"=>"2021-05-02T11:11:15Z",
            "billingPeriodStartedAt"=>"2021-09-02T11:11:15Z",
            "billingPeriodEndsAt"=>"2021-10-02T11:11:15Z"
          }
        ]
      }
    )
  end

  context 'filtering' do 
    it 'id_eq' do 
      authorized_request(@admin_user, query("(idEq: \"#{@user_2.id}\")")) 
      data = response.parsed_body['data']['users']

      expect(data.count).to eq(1)
      expect(data).to contain_exactly(
        {
          "id"=>@user_2.id.to_s,
          "email"=>"fork@alt-coin.com",
          "profile"=> {
            "id"=>@user_2.profile.id.to_s,
            "userId"=>@user_2.id.to_s,
            "firstName"=>"Satoshi",
            "lastName"=>"Nakamoto",
            "displayName"=>"#{@user_2.id} | Satoshi Nakamoto | #{@user_2.email}"
          },
        }
      )
    end

    it 'display_name_cont' do 
      authorized_request(@admin_user, query('(profileDisplayNameCont: "Spiegel")')) 
      data = response.parsed_body['data']['users']

      expect(data.count).to eq(1)
      expect(data).to contain_exactly(
        {
          "id"=>@user_1.id.to_s,
          "email"=>@user_1.email,
          "profile"=> {
            "id"=>@user_1.profile.id.to_s,
            "userId"=>@user_1.id.to_s,
            "firstName"=>"Spike",
            "lastName"=>"Spiegel",
            "displayName"=>"#{@user_1.id} | Spike Spiegel | #{@user_1.email}"
          }
        }
      )
    end
  end 

  def query(args = "", additional_fields = "")
    <<~GQL
      query {
        users#{args} {
          id
          email
          profile {
            id
            userId
            firstName
            lastName
            displayName
          }
          #{additional_fields}
        }
      }
    GQL
  end
end