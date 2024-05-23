// Dependencies
import * as React from 'react'
import * as Modal from 'react-modal'
import axios from 'axios'
import { t } from '../../src/locale'

// Props
interface PayBillModalProps {
  isOpen: boolean,
  onClose: any,
  paymentAmount: string,
  paymentDescription: string,
  paymentCardType: string,
  paymentCardLast4: string,
  changeCardUrl: string,
  checkoutUrl: string
}

// State
interface PayBillModalState {
  error: boolean,
  errorMessage: string,
  loading: boolean
}

/**
 * Pay Modal
 */
export default class PayBillModal extends React.Component<PayBillModalProps, PayBillModalState> {
  /**
   * Initial State
   */
  readonly state = {
    error: false,
    errorMessage: null,
    loading: false
  }

  /**
   * Constructor
   */
  constructor(props) {
    super(props)

    this.handleClose = this.handleClose.bind(this)
    this.handleSubmit = this.handleSubmit.bind(this)
  }

  /**
   * Handle updates to the component
   */
  componentDidUpdate(prevProps) {
    if (prevProps.isOpen == false && this.props.isOpen == true) {
      this.openModal()
    }
    if (prevProps.isOpen == true && this.props.isOpen == false) {
      this.closeModal()
    }
  }

  /**
   * Locks window scrolling
   */
  lockScrolling() {
    document.body.classList.add('lock-scrolling')
  }

  /**
   * Unlock window scrolling
   */
  unlockScrolling() {
    document.body.classList.remove('lock-scrolling')
  }

  /**
   * Opens the modal
   */
  openModal() {
    this.lockScrolling()
  }

  /**
   * Closes the modal
   */
  closeModal() {
    this.unlockScrolling()
    this.props.onClose.apply(this)
  }

  /**
   * Handles close button click
   */
  handleClose() {
    this.closeModal()
  }

  /**
   * Handles form submit
   */
  handleSubmit(event) {
    event.preventDefault()

    if ( ! confirm(`Are you sure? Your card will now be charged for ${this.props.paymentAmount}`)) {
      return;
    }

    this.setState({
      error: false,
      errorMessage: '',
      loading: true
    })

    const requestHeaders = { headers: { 'Content-Type': 'application/json' } }
    const request = axios
      .post(`${this.props.checkoutUrl}.json`, {}, requestHeaders)
      .then(response => {
        window.location.href = response.data.redirect_to
      }).catch(error => {
        this.setState({
          error: true,
          errorMessage: error.response.data.message,
          loading: false
        })
      })
  }

  /**
   * Modal overlay class names
   */
  modalOverlayClassName() {
    let classNames = ['pay-bill-modal__overlay']
    if (this.state.loading) {
      classNames.push('pay-bill-modal__overlay--loading')
    }
    return classNames.join(' ')
  }

  /**
   * Submit class names
   */
  submitClassName() {
    let classNames = ['btn', 'btn-dark', 'btn-block', 'pay-bill-modal__submit']
    if (this.state.loading) {
      classNames.push('btn-disabled')
    }
    return classNames.join(' ')
  }

  /**
   * Render
   */
  render() {
    return (
      <Modal
        isOpen={this.props.isOpen}
        onRequestClose={this.handleClose}
        ariaHideApp={false}
        overlayClassName={this.modalOverlayClassName()}
        className="pay-bill-modal"
      >
        <button className="pay-bill-modal__close" onClick={this.handleClose}></button>
        <div className="pay-bill-modal__body">
          { this.state.error &&
            <div className="alert alert-danger">{this.state.errorMessage}</div>
          }
          <h3 className="pay-bill-modal__title">{t('PayBillModal.Pay a bill')}</h3>
          <h1 className="pay-bill-modal__amount highlight highlight--orange">{this.props.paymentAmount}</h1>
          <p className="pay-bill-modal__subtitle">{this.props.paymentDescription}</p>
          <div className="pay-bill-modal__card">
            <h5 className="pay-bill-modal__card__title">{t('PayBillModal.Payment Card')}</h5>
            <span className="pay-bill-modal__card__details">💳 {window.gon.locale === 'ja' ? 'クレジットカードの下４桁' : this.props.paymentCardType+' ending'} **** **** **** {this.props.paymentCardLast4}</span>
            <a href={this.props.changeCardUrl} className="pay-bill-modal__card__change-link">{t('PayBillModal.Change')}</a>
          </div>
          <form onSubmit={this.handleSubmit}>
            <div className="form-group">
              <button type="submit" className={this.submitClassName()} disabled={this.state.loading}>
                <span className="pay-bill-modal__submit__text">{t('PayBillModal.Confirm Payment')}</span>
                <span className="pay-bill-modal__submit__spinner spinner-grow spinner-grow-sm" role="status" aria-hidden="true"></span>
              </button>
            </div>
          </form>
        </div>
      </Modal>
    );
  }
}
