// Dependencies
import * as React from 'react'
import * as Modal from 'react-modal'
import axios from 'axios'

// Props
interface BuySubscriptionModalProps {
  isOpen: boolean,
  onClose: any,
  subscriptionName: string,
  paymentAmount: string,
  paymentDescription: string,
  paymentCardType: string,
  paymentCardLast4: string,
  illustrationUrl: string,
  changeCardUrl: string,
  checkoutUrl: string
}

// State
interface BuySubscriptionModalState {
  error: boolean,
  errorMessage: string,
  loading: boolean
}

/**
 * Pay Modal
 */
export default class BuySubscriptionModal extends React.Component<BuySubscriptionModalProps, BuySubscriptionModalState> {
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
      .post(`${this.props.checkoutUrl}.json`, { subscription_name: this.props.subscriptionName }, requestHeaders)
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
    let classNames = ['buy-subscription-modal__overlay']
    if (this.state.loading) {
      classNames.push('buy-subscription-modal__overlay--loading')
    }
    return classNames.join(' ')
  }

  /**
   * Submit class names
   */
  submitClassName() {
    let classNames = ['btn', 'btn-dark', 'btn-block', 'buy-subscription-modal__submit']
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
        className="buy-subscription-modal"
      >
        <button className="buy-subscription-modal__close" onClick={this.handleClose}></button>
        <div className="buy-subscription-modal__body">
          { this.state.error &&
            <div className="alert alert-danger">{this.state.errorMessage}</div>
          }
          <img src={this.props.illustrationUrl} className="buy-subscription-modal__illustration" />
          <h3 className="buy-subscription-modal__title">Confirm Subscription</h3>

          <h1 className="buy-subscription-modal__amount highlight">{this.props.paymentAmount}<span className="buy-subscription-modal__duration">p/mo</span></h1>

          <p className="buy-subscription-modal__subtitle">{this.props.paymentDescription}</p>
          <div className="buy-subscription-modal__card">
            <h5 className="buy-subscription-modal__card__title">Payment Card</h5>
            <span className="buy-subscription-modal__card__details">💳 {this.props.paymentCardType} ending **** **** **** {this.props.paymentCardLast4}</span>
            <a href={this.props.changeCardUrl} className="buy-subscription-modal__card__change-link">Change</a>
          </div>
          <form onSubmit={this.handleSubmit}>
            <div className="form-group">
              <button type="submit" className={this.submitClassName()} disabled={this.state.loading}>
                <span className="buy-subscription-modal__submit__text">Confirm Payment</span>
                <span className="buy-subscription-modal__submit__spinner spinner-grow spinner-grow-sm" role="status" aria-hidden="true"></span>
              </button>
            </div>
          </form>
        </div>
      </Modal>
    );
  }
}
