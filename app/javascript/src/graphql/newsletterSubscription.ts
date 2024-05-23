import {gql} from "@apollo/client"

export const NewsletterSubscription = {
    SubscribeRequest: gql`
    mutation ($input: NewsletterSubscriptionMutationInput!) {
        newsletterSubscription(input: $input){
            success
            message
            status
        }
    }
  `
}
