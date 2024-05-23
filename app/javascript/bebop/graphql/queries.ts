import { gql } from "@apollo/client"
import { Fragments } from "./fragments"

// MARK: Users

export const USERS = gql`
  query {
    users {
      ...UserFields
    }
  }
  ${Fragments.UserFields}
`

export const USERS_WITH_SUBSCRIPTIONS = gql`
  query users($idEq: ID) {
    users(idEq: $idEq) {
      ...UserFields
      subscriptions {
        ...SubscriptionFields
      }
    }
  }
  ${Fragments.UserFields}
  ${Fragments.SubscriptionFields}
`

// MARK: Assistant

export const ASSISTANT_TASKS = gql`
  query assistantTasks($userId: ID!, $stateIn: [String!]) {
    assistantTasks(userId: $userId, stateIn: $stateIn) {
      ...AssistantTaskFields
    }
  }
  ${Fragments.AssistantTaskFields}
`

// MARK: Mail

export const MAIL_RECIPIENT_WITH_INBOX_AND_USER = gql`
  query mailRecipients($idEq: ID) {
    mailRecipients(idEq: $idEq) {
      ...MailRecipientFields
      inbox {
        ...MailInboxFields
        user {
          ...UserFields
          subscriptions {
            ...SubscriptionFields
          }
        }
      }
    }
  }
  ${Fragments.MailRecipientFields}
  ${Fragments.MailInboxFields}
  ${Fragments.UserFields}
  ${Fragments.SubscriptionFields}
`