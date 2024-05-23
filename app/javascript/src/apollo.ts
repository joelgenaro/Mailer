import { ApolloClient, InMemoryCache, createHttpLink, from } from '@apollo/client'
import { onError } from "@apollo/link-error"

const httpLink = createHttpLink({
  uri: `${window.location.origin}/graphql`
})


const errorLink = onError(({ graphQLErrors, networkError }) => {
  if (graphQLErrors) {
    graphQLErrors?.forEach(error => {
      // Check for errors in future
    })

    graphQLErrors.map(({ message, locations, path }) =>
      console.log(
        `[GraphQL error]: Message: ${message}, Location: ${locations}, Path: ${path}`,
      )
    )
  }
  if (networkError) console.log(`[Network error]: ${networkError}`);
})

export const client = new ApolloClient({
  cache: new InMemoryCache(),
  link: from([errorLink, httpLink]),
  defaultOptions: { // Disable cache, we don't use this mechanism
    watchQuery: {
      fetchPolicy: 'network-only',
    },
    query: {
      fetchPolicy: 'network-only',
    }
  }
})  

/**
 * Custom error class, for setting a message to show, 
 * so can reuse error handling code, example:
 * // Show error message (API error vs execution error)
 * let errorMessage = (error instanceof APIMessageError) ? error.message : messageForApolloErrorType(typeForApolloError(error))
 */
 export class APIMessageError extends Error {
  constructor(m: string) {
    super(m)
    Object.setPrototypeOf(this, APIMessageError.prototype) // Set the prototype explicitly.
  }
}

/**
 * Enum for types of errors from the api
 */
 enum ApolloErrorType {
  ClientException,
  Authentication,
  InvalidRequest,
  Network,
  InternalError,
  Unknown
}

/**
 * Returns the type for the error from Apollo
 * @param error error from the client
 */
export const typeForApolloError = (error: any): ApolloErrorType => {
  // Client Exception
  if (error.graphQLErrors === undefined && error.networkError === undefined) {
    // If not Apollo error, then its an exception caused by us (doh!).
    // Log it, raise it to Sentry and carry on my wayward son.
    console.log(error)
    // Sentry.captureException(error)
    return ApolloErrorType.ClientException
  }
  // Authentication error 
  else if (error.graphQLErrors[0]?.extensions?.type === 'NOT_AUTHENTICATED') {
    return ApolloErrorType.Authentication
  }
  // Invalid Request
  else if (error.graphQLErrors[0]?.extensions?.type === 'INVALID_REQUEST') {
    return ApolloErrorType.InvalidRequest
  }
  // Network error 
  else if (error.networkError) {
    // Internal error (or not found)
    if (error.networkError.statusCode === 500) {
      return ApolloErrorType.InternalError
    }
    // Otherwise generic network error
    else {
      return ApolloErrorType.Network
    }
  }
  // Unknown error
  else {
    return ApolloErrorType.Unknown
  }
}

/**
 * Returns a message to display to user, based on the type of error
 * @param apolloErrorType error to base message on
 */
export const messageForApolloErrorType = (apolloErrorType: ApolloErrorType): string => {
  // Client Exception error
  if (apolloErrorType === ApolloErrorType.ClientException) {
    return 'Client exception, please try again or contact support'
  }
  // Authentication error 
  else if (apolloErrorType === ApolloErrorType.Authentication) {
    return 'Error authenticating, please ensure you are signed in'
  }
  // Authorization error
  else if (apolloErrorType === ApolloErrorType.InvalidRequest) {
    return 'Invalid request'
  }
  // Internal Error
  else if (apolloErrorType === ApolloErrorType.InternalError) {
    return 'Internal error, please try again'
  }
  // Network error 
  else if (apolloErrorType === ApolloErrorType.Network) {
    return 'Network error, please check your internet connection'
  }
  // Fallback Unknown error
  else {
    return 'Unknown error, please try again'
  }
}