import _ from 'lodash'
import React from 'react' 
import Select, { OptionTypeBase } from 'react-select'
import styled from 'styled-components'
import { MAIL_RECIPIENT_WITH_INBOX_AND_USER } from '../../bebop/graphql/queries'
import { IMailRecipient, ISubscription } from '../../bebop/graphql/types'
import { APIMessageError, client, messageForApolloErrorType, typeForApolloError } from "../../bebop/lib/apollo"

interface PostalMailsInboxSelectorProps {
  initialMailReciepentId?: string,
  selectOptions?: OptionTypeBase[]
}

interface PostalMailsInboxSelectorState {
  isLoading: boolean,
  errorMessage?: string,

  selectedOption?: OptionTypeBase,
  mailRecipient?: IMailRecipient
  subscription?: ISubscription
}

/**
 * Selector a Mail::Inbox, displaying the relevant details and setting form field.
 * for use in on the Admin task pages: app/admin/postal_mails.rb
 */
export default class PostalMailsInboxSelector extends React.Component<PostalMailsInboxSelectorProps, PostalMailsInboxSelectorState> {

  readonly state: PostalMailsInboxSelectorState = {
    isLoading: false
  }

  constructor(props: PostalMailsInboxSelectorProps) {
    super(props)

    this.state = {
      isLoading: false,
      selectedOption: _.find(props.selectOptions, { value: props.initialMailReciepentId }) // If none, will just be undefined
    }
  }

  componentDidMount() {
    // If an initial mail recipient, then fetch it
    if (this.props.initialMailReciepentId) {
      this.fetchMailRecipient(this.props.initialMailReciepentId)
    }
  }

  render() {
    return (
      <>
        {/* Select */}
        <Row>
          <Label>Recipient<abbr title="required">*</abbr></Label>
          <Select
            name="mail_postal_mail[mail_recipient_id]"
            value={this.state.selectedOption}
            onChange={selectedOption => {
              // If selected user changes, get the tasks for them
              if (selectedOption.value != this.state.selectedOption?.value) {
                this.fetchMailRecipient(selectedOption.value)
              }
              this.setState({ selectedOption: selectedOption })
            }}
            options={this.props.selectOptions}
            placeholder={'Select recipient'}
            isDisabled={this.state.isLoading}
            styles={reactSelectStyles}
          />
        </Row>

        {/* Details */}
        <Row>
          <Label /> {/* Used for spacing */}
          <Panel>
            {/* Loading */}
            {this.state.isLoading && (
              <p><i>Loading...</i></p>
            )}

            {/* Error Message */}
            {this.state.errorMessage && !this.state.isLoading &&  (
              <p><b>{this.state.errorMessage}</b></p>
            )}

            {/* Placeholder */}
            {!this.state.mailRecipient && !this.state.errorMessage && !this.state.isLoading && (
              <p><i>Select reciepent...</i></p>
            )}

            {/* Mail Recipient */}
            {this.state.mailRecipient && !this.state.errorMessage && !this.state.isLoading && (
              <table>
                <thead>
                  <tr>
                    <th colSpan={2}>User</th>
                    <th colSpan={2}>Subscription</th>
                    <th colSpan={2}>Credits</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td><b>Name</b></td>
                    <td>{this.state.mailRecipient.inbox.user.profile.firstName} {this.state.mailRecipient.inbox.user.profile.lastName}</td>

                    <td><b>Plan</b></td>
                    <td>{this.state.subscription.plan}</td>

                    <td><b>Mail Content Scan</b></td>
                    <td>{this.state.mailRecipient.inbox.creditBalanceMailContentScan}</td>
                  </tr>
                  <tr>
                    <td><b>Email</b></td>
                    <td>{this.state.mailRecipient.inbox.user.email}</td>

                    <td><b>Status</b></td>
                    <td>{this.state.subscription.status}</td>

                    <td><b>Mail Translation Summary</b></td>
                    <td>{this.state.mailRecipient.inbox.creditBalanceMailTranslationSummary}</td>
                  </tr>
                </tbody>
              </table>
            )}
          </Panel>
        </Row>
      </>
    )
  }

  // MARK: API 

  async fetchMailRecipient(mailRecipientId: string) {
    this.setState({ isLoading: true, mailRecipient: undefined, subscription: undefined, errorMessage: undefined })

    try {
      let response = await client.query({ 
        query: MAIL_RECIPIENT_WITH_INBOX_AND_USER,
        variables: {
          idEq: mailRecipientId
        }
      })

      // Handle if no mail recipient found
      if (response.data.mailRecipients.length === 0) {
        throw new APIMessageError(`Recipient not found for id ${mailRecipientId}`)
      }

      // Handle if no mail subscription found
      let mailRecipient: IMailRecipient = _.first(response.data.mailRecipients)
      let subscription: ISubscription = _.find(mailRecipient.inbox.user.subscriptions, ['planType', 'mail'])
      if (!subscription) {
        throw new APIMessageError(`No mail subscription found for user ${mailRecipient.inbox.user.email}`)
      }
      // Set the things
      this.setState({ isLoading: false, mailRecipient: mailRecipient, subscription: subscription })
    }
    catch(error) {
      let errorMessage = (error instanceof APIMessageError) ? error.message : messageForApolloErrorType(typeForApolloError(error))
      this.setState({ isLoading: false, errorMessage: errorMessage })
    }
  }
}


// MARK: Components
// We basically wholesale copy ActiveAdmins styles until everything is redone in Bebop

const Row = styled.div`
  padding: 10px;
  display: flex;
`

const Label = styled.label`
  display: block;
  flex-shrink: 0;
  width: 20%;
  float: left;
  font-size: 1.0em;
  font-weight: bold;
  color: #5E6469;
  abbr {
    border: none;
    color: #aaa;
  }
`

const reactSelectStyles = {
  container: (provided, state) => ({
    ...provided,
    height: '42px',
    width: '100%'
  }),
  input: (provided) => ({
    ...provided,
    'input': {
      boxShadow: 'none !important'
    }
  }),
}

const Panel = styled.div`
  background-color: white;
  border-radius: 6px;
  padding: 15px;
  width: 100%;
  border: 1px solid #c9d0d6;
`