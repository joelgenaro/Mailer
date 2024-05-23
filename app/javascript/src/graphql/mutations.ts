import { gql } from "@apollo/client"

// MARK: Assistant

export const ASSISTANT_PURCHASE_ADDITIONAL_TIME_MUTATION = gql`
  mutation($input: AssistantPurchaseAdditionalTimeMutationInput!) {
    assistantPurchaseAdditionalTime(input: $input) {
      success
      errorMessage
    }
  }
`