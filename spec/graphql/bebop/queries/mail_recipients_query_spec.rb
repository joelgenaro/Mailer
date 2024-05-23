require 'rails_helper'

RSpec.describe Bebop::Queries::MailRecipientsQuery, type: :request do
  include BebopGraphQLHelper

  before(:all) do 
    @admin_user = create(:admin_user)

    # Subscription factory will create Mail::Inbox, which will create Mail::Recipient
    User.destroy_all

    @user_1 = create(:user, :with_profile)
    @subscription_1 = create(:subscription, :with_plan_mail, :with_status_active, user: @user_1)
    @mail_recipient_1 = @user_1.inbox.recipients.last
    create(:mail_credit_transaction, :credit_type__mail_content_scan__income__subscription, inbox: @user_1.inbox)
    create(:mail_credit_transaction, :credit_type__mail_translation_summary__income__additional_purchase, inbox: @user_1.inbox)

    @user_2 = create(:user, :with_profile, email: "fork@alt-coin.com")
    @user_2.profile.update(first_name: "Satoshi", last_name: "Nakamoto")
    @subscription_2 = create(:subscription, :with_plan_mail, :with_status_active, user: @user_2)
    @mail_recipient_2 = @user_2.inbox.recipients.last
  end

  it 'authenticates admin' do
    ensure_admin_user_authenticated(query) 
  end

  it 'returns mail recipients' do 
    authorized_request(@admin_user, query) 
    data = response.parsed_body['data']['mailRecipients']

    expect(data.count).to eq(2)
    expect(data).to contain_exactly(
      {
        "id" => @mail_recipient_1.id.to_s,
        "name" => @mail_recipient_1.name,
        "addressEn" => @mail_recipient_1.address_en,
        "addressJp" => @mail_recipient_1.address_jp,
        "inbox" => {
          "id" => @mail_recipient_1.inbox.id.to_s,
          "autoOpenMail" => false,
          "autoPayBills" => false,
          "autoPayLimitAmount" => 10000,
          "autoPayLimitIsUnlimited" => false,
          "creditBalanceMailContentScan" => 15,
          "creditBalanceMailTranslationSummary" => 3,
          "user" => {
            "id" => @user_1.id.to_s,
            "email" => @user_1.email,
            "profile" => {
              "id" => @user_1.profile.id.to_s,
              "userId" => @user_1.id.to_s,
              "firstName" => "Spike",
              "lastName" => "Spiegel",
              "displayName" => @user_1.profile.display_name
            },
            "subscriptions" => [
              {
                "id" => @subscription_1.id.to_s,
                "userId" => @user_1.id.to_s,
                "planType" => "mail",
                "plan" => "mail_standard",
                "status" => "active",
                "stripeSubscriptionId" => @subscription_1.stripe_subscription_id,
                "billingStartedAt" => @subscription_1.billing_started_at.iso8601,
                "billingPeriodStartedAt" => @subscription_1.billing_period_started_at.iso8601,
                "billingPeriodEndsAt" => @subscription_1.billing_period_ends_at.iso8601
              }
            ]
          }
        }
      },
      {
        "id" => @mail_recipient_2.id.to_s,
        "name" => @mail_recipient_2.name,
        "addressEn" => @mail_recipient_2.address_en,
        "addressJp" => @mail_recipient_2.address_jp,
        "inbox" => {
          "id" => @mail_recipient_2.inbox.id.to_s,
          "autoOpenMail" => false,
          "autoPayBills" => false,
          "autoPayLimitAmount" => 10000,
          "autoPayLimitIsUnlimited" => false,
          "creditBalanceMailContentScan" => 0,
          "creditBalanceMailTranslationSummary" => 0,
          "user" => {
            "id" => @user_2.id.to_s,
            "email" => "fork@alt-coin.com",
            "profile" => {
              "id" => @user_2.profile.id.to_s,
              "userId" => @user_2.id.to_s,
              "firstName" => "Satoshi",
              "lastName" => "Nakamoto",
              "displayName" => "#{@user_2.id.to_s} | Satoshi Nakamoto | fork@alt-coin.com"
            },
            "subscriptions" => [
              {
                "id" => @subscription_2.id.to_s,
                "userId" => @user_2.id.to_s,
                "planType" => "mail",
                "plan" => "mail_standard",
                "status" => "active",
                "stripeSubscriptionId" => @subscription_2.stripe_subscription_id,
                "billingStartedAt" => @subscription_2.billing_started_at.iso8601,
                "billingPeriodStartedAt" => @subscription_2.billing_period_started_at.iso8601,
                "billingPeriodEndsAt" => @subscription_2.billing_period_ends_at.iso8601
              }
            ]
          }
        }
      }
    )
  end

  context 'filtering' do 
    it 'id_eq' do 
      authorized_request(@admin_user, query("(idEq: \"#{@mail_recipient_2.id}\")")) 
      data = response.parsed_body['data']['mailRecipients']

      expect(data.count).to eq(1)
      expect(data).to contain_exactly(
        {
          "id" => @mail_recipient_2.id.to_s,
          "name" => @mail_recipient_2.name,
          "addressEn" => @mail_recipient_2.address_en,
          "addressJp" => @mail_recipient_2.address_jp,
          "inbox" => {
            "id" => @mail_recipient_2.inbox.id.to_s,
            "autoOpenMail" => false,
            "autoPayBills" => false,
            "autoPayLimitAmount" => 10000,
            "autoPayLimitIsUnlimited" => false,
            "creditBalanceMailContentScan" => 0,
            "creditBalanceMailTranslationSummary" => 0,
            "user" => {
              "id" => @user_2.id.to_s,
              "email" => "fork@alt-coin.com",
              "profile" => {
                "id" => @user_2.profile.id.to_s,
                "userId" => @user_2.id.to_s,
                "firstName" => "Satoshi",
                "lastName" => "Nakamoto",
                "displayName" => "#{@user_2.id.to_s} | Satoshi Nakamoto | fork@alt-coin.com"
              },
              "subscriptions" => [
                {
                  "id" => @subscription_2.id.to_s,
                  "userId" => @user_2.id.to_s,
                  "planType" => "mail",
                  "plan" => "mail_standard",
                  "status" => "active",
                  "stripeSubscriptionId" => @subscription_2.stripe_subscription_id,
                  "billingStartedAt" => @subscription_2.billing_started_at.iso8601,
                  "billingPeriodStartedAt" => @subscription_2.billing_period_started_at.iso8601,
                  "billingPeriodEndsAt" => @subscription_2.billing_period_ends_at.iso8601
                }
              ]
            }
          }
        }
      )
    end
  end 

  def query(args = "")
    <<~GQL
      query {
        mailRecipients#{args} {
          id
          name
          addressEn
          addressJp
          inbox {
            id
            autoOpenMail
            autoPayBills
            autoPayLimitAmount
            autoPayLimitIsUnlimited
            creditBalanceMailContentScan
            creditBalanceMailTranslationSummary
            user {
              id
              email
              profile {
                id
                userId
                firstName
                lastName
                displayName
              }
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
            }
          }
        }
      }
    GQL
  end
end