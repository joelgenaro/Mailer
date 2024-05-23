import { gql, useMutation } from '@apollo/client'
import React, { useState } from 'react'
import { client } from '../../../src/apollo'
import { Fragments } from '../../../src/graphql/fragments'
import { ICreateMailForwardRequestMutationPayload, IMailForwardRequest } from '../../../src/graphql/types'
import { t } from '../../../src/locale'
import GenericModal from '../../generic_modal'

/**
 * Modal for requesting forwards for mail items
 */
const MailForwardRequestModal: React.FC<{
  isOpen: boolean,
  onRequestClose: () => void,
  postalMailId: string,
  onForwardRequestCreated: (forwardRequest: IMailForwardRequest) => void
}> = (props) => {
  const [showSuccess, setShowSuccess] = useState(false)
  const [errorMessage, setErrorMessage] = useState<string>(undefined)
  const [address, setAddress] = useState('')

  const [mutate, { loading }] = useMutation(
    gql`
      mutation($input: CreateMailForwardRequestMutationInput!) {
        createMailForwardRequest(input: $input) {
          success
          errorMessage
          forwardRequest {
            ...MailForwardRequestFields
          }
        }
      }
      ${Fragments.MailForwardRequestFields}
    `, 
    {
      client: client,
      variables: { input: { postalMailId: props.postalMailId, address } },
      onCompleted(data) {
        let createMailForwardRequest: ICreateMailForwardRequestMutationPayload = data.createMailForwardRequest

        if (createMailForwardRequest.success) { // Call handler and show success
          setShowSuccess(true)
          props.onForwardRequestCreated(createMailForwardRequest.forwardRequest)
        }
        else { // Cry
          setErrorMessage(createMailForwardRequest.errorMessage || 'Error, please try again')
        }
      },
      onError(error) {
        setErrorMessage('Unable to submit, please try again')
      }
    }
  )

  return (
    <GenericModal
      isOpen={props.isOpen}
      onRequestClose={props.onRequestClose}
      onAfterClose={() => {
        // Reset state, as user may open, close, reopen, etc
        setShowSuccess(false)
        setErrorMessage(undefined)
        setAddress('')
      }}
    >
      <h2 className="mt-1">{t("MailForwardRequestModal.Mail Forward Request")}</h2>

      {showSuccess && (
        <>
          <div className="alert alert-primary mt-3" style={{height: '100%'}}>
            Mail forward successfully requested to "{address}". We will be in touch with further details.
          </div>
        </>
      )}

      {!showSuccess && (
        <>
          {errorMessage && <div className="alert alert-danger" style={{height: '100%'}}>{errorMessage}</div>}
          <p>{t("MailForwardRequestModal.Body")}</p>
          <textarea 
            className="form-control mb-2"
            placeholder={t('MailForwardRequestModal.Address to forward to')}
            value={address}
            onChange={e => setAddress(e.target.value)}
            disabled={loading}
          />
          <button
            className="btn btn-dark btn-block mail__submit"
            disabled={loading}
            onClick={() => {
              setErrorMessage(undefined) // Reset all
              if (address.length < 10) { // Ensure address
                setErrorMessage('Address must be at least 10 characters')
                return
              }
              mutate() // Make the request
            }}
          >
            {loading ? '...' : t(`MailForwardRequestModal.Request Forward`)}
          </button>
        </>
      )}
    </GenericModal>
  )
}
export default MailForwardRequestModal
