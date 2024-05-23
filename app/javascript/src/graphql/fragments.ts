import { gql } from "@apollo/client"

export const Fragments = {
  MailForwardRequestFields: gql`
    fragment MailForwardRequestFields on MailForwardRequest {
      id
      address
      state
      requestedAt
      forwardedAt
    }
  `
}
