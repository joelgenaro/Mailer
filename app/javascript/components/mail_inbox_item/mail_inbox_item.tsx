// Dependencies
import React from 'react'
import { gql } from '@apollo/client'
import { client } from '../../src/apollo'
import Loader from '../loader'
import MailItems from '../mail_items'
import MailNotes from '../mail_notes'
import PayBillButton from '../pay_bill_button'
import { DateTime } from 'luxon'
import MailForwardRequestModal from './components/mail_forward_request_modal'
import { Fragments } from '../../src/graphql/fragments'
import { IPostalMail } from '../../src/graphql/types'
import IconForward from '-!react-svg-loader!./assets/icon-forward.svg'
import IconArchive from '-!react-svg-loader!./assets/icon-archive.svg'
import IconUnarchive from '-!react-svg-loader!./assets/icon-unarchive.svg'
import IconDelete from '-!react-svg-loader!./assets/icon-delete.svg'
import IconShred from '-!react-svg-loader!./assets/icon-shred.svg'
import { Tooltip } from 'react-tippy'
import { t } from '../../src/locale'

declare global { interface Window { Intercom:any } }

// Props
interface MailInboxItemProps {
  id: string
}

// State
interface MailInboxItemState {
  item: object,
  isLoading: boolean,
  forwardModalIsOpen: boolean
}

const POSTAL_MAIL = gql`
  query postalMail($id: ID!) {
    postalMail(id: $id) {
      id
      receivedOn
      receivedOnAbbv
      state
      stateHumanized
      notes
      openUrl
      mailItems {
        thumbnail
        large
        url
      }
      bill {
        state
        totalWithCurrency
        subtotalWithCurrency
        processingFeeWithCurrency
        description
        dueDate
        dueDateAbbv
        checkoutUrl
      }
      user {
        defaultPaymentMethod {
          cardType
          cardLast4
        }
        changeCardUrl
      }
      forwardRequest {
        ...MailForwardRequestFields
      }
      toggleArchiveUrl
      archived
      deleteMailUrl
      shred
      shredMailUrl
    }
  }
  ${Fragments.MailForwardRequestFields}
`

/**
 * Mail Inbox
 */
export default class MailInboxItem extends React.Component<MailInboxItemProps, MailInboxItemState> {
  /**
   * Initial State
   */
  readonly state = {
    item: null,
    isLoading: true,
    forwardModalIsOpen: false
  }

  /**
   * Component did mounted
   */
  componentDidMount() {
    this.fetchItem()
  }

  /**
   * Component did update
   */
  componentDidUpdate(prevProps) {
    if (prevProps.id !== this.props.id) {
      this.fetchItem()
    }
  }

  /**
   * Fetches the postal_mail
   */
  async fetchItem() {
    this.setState({ isLoading: true })

    await client.query({ 
      query: POSTAL_MAIL,
      variables: {
        id: this.props.id
      }
    }).then(({ data }) => {
      this.setState({
        item: data.postalMail,
        isLoading: false
      })
    })
  }

  /**
   * Shows Intercom window with prepopulated message
   */
  onClickAskQuestionButton() {
    window.Intercom(
      'showNewMessage',
      `Inquiry about Mail ${this.props.id}:\n`
    )
  }
  /**
   * Returns the bill payment text
   */
  billPaymentText(bill) {
    if (bill.dueDateAbbv == null) {
      return t('MailInboxItem.This mail contains an unpaid bill for ${totalWithCurrency}', { totalWithCurrency: bill.totalWithCurrency })
    } else {
      const dueDate = (window.gon.locale === 'ja') ? DateTime.fromISO(bill.dueDate).toFormat('yyyy/MM/dd') : bill.dueDateAbbv
      return t('MailInboxItem.This mail contains an unpaid bill for ${totalWithCurrency} due on ${dueDate}', { totalWithCurrency: bill.totalWithCurrency, dueDate: dueDate })
    }
  }

  /**
   * Renders the loading state
   */
  buildLoader() {
    return (
      <div className="mail__loading">
        <Loader isLoading={this.state.isLoading} />
      </div>
    )
  }

  /**
   * Renders the open mail alert
   */
  buildOpenAlert(item) {
    return (
      <div className="mail__alert alert alert-primary">
        <p className="mail__alert__text">{t(`MailInboxItem.This mail has not yet been opened`)}</p>
        <div className="mail__alert__action">
          <a href={item.openUrl} data-method="patch" className="btn btn-teal btn-block">{t(`MailInboxItem.Open It`)}</a>
        </div>
      </div>
    )
  }

  /**
   * Renders the opening mail alert
   */
  buildOpeningAlert(item) {
    return (
      <div className="mail__alert alert alert-primary">
        <p className="mail__alert__text">You've requested this mail to be opened and it will be updated soon.</p>
      </div>
    )
  }

  /**
   * Renders the payment alert
   */
  buildPaymentAlert(item) {
    return (
      <div className="mail__alert alert alert-danger">
        <p className="mail__alert__text">{this.billPaymentText(item.bill)}</p>
        <div className="mail__alert__action">
          <PayBillButton
            buttonText={t("MailInboxItem.Pay Bill")}
            buttonClass="btn btn-orange btn-block"
            paymentAmount={item.bill.totalWithCurrency}
            paymentDescription={`${item.bill.description}. ${item.bill.subtotalWithCurrency} + ${item.bill.processingFeeWithCurrency} ${window.gon.locale === 'ja' ? '手数料' : 'processing fee'}.`}
            paymentCardType={item.user.defaultPaymentMethod.cardType}
            paymentCardLast4={item.user.defaultPaymentMethod.cardLast4}
            changeCardUrl={item.user.changeCardUrl}
            checkoutUrl={item.bill.checkoutUrl}
          />
        </div>
      </div>
    )
  }

  /**
   * Renders the "bill paid" alert
   */
  buildPaidAlert(item) {
    return (
      <div className="mail__alert alert alert-primary">
        <p className="mail__alert__text">This bill has been paid. No further action required.</p>
      </div>
    )
  }

  /**
   * Renders the item
   */
  buildItem(item) {
    const receivedOnDate = DateTime.fromISO(item.receivedOn)

    return (
      <div className="mail__content">
        <MailItems items={item.mailItems} mailId={this.props.id} />
        <div className="mail__content-item">
          <div className="mail__label">{t('MailInboxItem.Received On')}</div>
          <div className="mail__field">{window.gon.locale === 'ja' ? receivedOnDate.toFormat('yyyy/MM/dd') : item.receivedOnAbbv}</div>
        </div>
        <div className="mail__content-item">
          <div className="mail__label">{t('MailInboxItem.Status')}</div>
          <div className="mail__field">{t(`MailInbox.PostalMail.StateHumanized.${item.stateHumanized}`)}</div>
        </div>

        {/* Forwarding (with modal) */}
        {this.buildForwardRequestModal()}
        {item.forwardRequest && (
          <div className="mail__content-item">
            <div className="mail__label">{t('MailInboxItem.Forwarding')}</div>
            {item.forwardRequest.state == 'requested' && (
              <div className="mail__field">Requested on {DateTime.fromISO(item.forwardRequest.requestedAt).toFormat('EEE d MMM yy')}, to be sent to "{item.forwardRequest.address}"</div>
            )}
            {item.forwardRequest.state == 'forwarded' && (
              <div className="mail__field">Forwarded on {DateTime.fromISO(item.forwardRequest.forwardedAt).toFormat('EEE d MMM yy')}, to "{item.forwardRequest.address}"</div>
            )}
          </div>
        )}

        <div className="mail__content-item">
          {/* Question Button */}
          <div className="mail__label">{t('MailInboxItem.Notes')}</div>
          <div className="mail__field">
            <MailNotes id={this.props.id} text={item.notes} />
          </div>

          {/* Question Button */}
          <button className="mt-2 btn btn-outline-dark btn-block" onClick={this.onClickAskQuestionButton.bind(this)}>{t('MailInboxItem.Question? Chat with the TokyoMate Team')}</button>
        </div>
      </div>
    )
  }
  /**
   * Returns the forward request modal, all hooked up
   */
  buildForwardRequestModal() {
    return (
      <MailForwardRequestModal
        isOpen={this.state.forwardModalIsOpen}
        onRequestClose={() => this.setState({forwardModalIsOpen: false})}
        postalMailId={this.props.id}
        onForwardRequestCreated={forwardRequest => {
          // Swap out forwardRequest on item, so reflects in UI
          let item: IPostalMail = {...this.state.item}
          item.forwardRequest = forwardRequest
          this.setState({ item })
        }}
      />
    )
  }

  /**
   * Render
   */
  render() {
    const { item } = this.state

    return (
      <>
        <div className="mail">
          {this.state.isLoading && this.buildLoader()}
          {!this.state.isLoading &&
            <div className="mail__container">

              <div className="mail__header">
                <div className="mail__header__col mail__header__col--grow">
                  <h1 className="mail__header__title">{item.notes}</h1>
                  <span className="mail__header__subtitle">{window.gon.locale === 'ja' ? DateTime.fromISO(item.receivedOn).toFormat('yyyy/MM/dd') : `Received ${item.receivedOnAbbv}` }</span>
                </div>
                <div className="mail__header__col">
                  {!this.state.item.archived && (
                    <Tooltip position="top" size="small" title="Archive mail" animateFill={false} distance={3}>
                     <a href={item.toggleArchiveUrl} data-method="patch" className="mail__header__button">
                        <IconArchive />
                        </a>
                    </Tooltip>
                  )}
                  {this.state.item.archived && (
                    <Tooltip position="top" size="small" title="Unarchive mail" animateFill={false} distance={3}>
                     <a href={item.toggleArchiveUrl} data-method="patch" className="mail__header__button">
                        <IconUnarchive />
                        </a>
                    </Tooltip>
                  )}
                </div>
                <div className="mail__header__col">
                  {/* Forward Request Button (if none) */}
                  {!this.state.item.forwardRequest && (
                    <Tooltip position="top" size="small" title={t("MailInboxItem.Forward mail")} animateFill={false} distance={3}>
                      <button className="mail__header__button" onClick={() => this.setState({forwardModalIsOpen: true})}>
                        <IconForward />
                      </button>
                    </Tooltip>
                  )}
                </div>
                <div className="mail__header__col">
                  <Tooltip position="top" size="small" title="Delete mail" animateFill={false} distance={3}>
                      <a href={item.deleteMailUrl} className="mail__header__button" data-confirm="Are you sure you want to delete this mail? This cannot be reversed." data-method="patch">
                      <IconDelete />
                      </a>
                    </Tooltip>
                </div>
                <div className="mail__header__col">
                {!this.state.item.shred && (
                    <Tooltip position="top" size="small" title="Shred mail" animateFill={false} distance={3}>
                      <a href={item.shredMailUrl} className="mail__header__button" data-confirm="Are you sure you want to shred this mail? This will destroy your physical postal mail permanently." data-method="patch">
                      <IconShred />
                      </a>
                    </Tooltip>
                )}
                </div>
              </div>
              {item.state == 'unopened' && this.buildOpenAlert(item)}
              {item.state == 'opening' && this.buildOpeningAlert(item)}
              {item.bill && item.bill.state == 'pending' && this.buildPaymentAlert(item)}
              {item.bill && item.bill.state != 'pending' && this.buildPaidAlert(item)}
              {this.buildItem(item)}
            </div>
          }
        </div>
      </>
    )
  }
}
