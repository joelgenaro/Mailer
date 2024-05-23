import { gql } from "@apollo/client"

export const Fragments = {
  // MARK: User
  UserFields: gql`
    fragment UserFields on User {  
      id
      email
      profile {
        id
        userId
        firstName
        lastName
        displayName
      }
    }
  `,
  SubscriptionFields: gql`
    fragment SubscriptionFields on Subscription {  
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
  `,
  // MARK: Assistant
  AssistantTaskFields: gql`
    fragment AssistantTaskFields on AssistantTask {  
      id
      userId
      label 
      state
    }
  `,
  // MARK: Mail
  MailRecipientFields: gql`
    fragment MailRecipientFields on MailRecipient {  
      id
      name
      addressEn
      addressJp
    }
  `,
  MailInboxFields: gql`
    fragment MailInboxFields on MailInbox {  
      id
      autoOpenMail
      autoPayBills
      autoPayLimitAmount
      autoPayLimitIsUnlimited
      creditBalanceMailContentScan
      creditBalanceMailTranslationSummary
    }
  `,
}