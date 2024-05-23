import { gql } from "@apollo/client"

export const SEND_ADDITIONAL_TIME_EMAIL_MUTATION = gql`
  mutation($input: SendAdditionalTimeEmailMutationInput!) {
    sendAdditionalTimeEmail(input: $input) {
      success
      errorMessage
    }
  }
`