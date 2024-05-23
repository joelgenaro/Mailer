// Dependencies
import * as React from 'react'
import * as Modal from 'react-modal'
import axios from 'axios'
import { loadStripe } from '@stripe/stripe-js'

// Environment Variables
declare const gon: any

// Make sure to call `loadStripe` outside of a component’s render to avoid
// recreating the `Stripe` object on every render.
const stripePromise = loadStripe(gon.stripe_publishable_key);

// Props
interface SignupModalButtonProps {
  buttonText: string,
  buttonClass: string,
  subscriptionName: string,
  subscriptionType: string,
  logoUrl: string,
  signupUrl: string,
  termsOfServiceUrl: string,
  initOpenModal: boolean
}

// State
interface SignupModalButtonState {
  showModal: boolean,
  userEmail: string,
  userPassword: string,
  termsAgreed: boolean,
  error: boolean,
  errorMessage: string,
  loading: boolean
}

/**
 * Signup Modal Button
 */
export default class SignupModalButton extends React.Component<SignupModalButtonProps, SignupModalButtonState> {
  isJP = (window.gon.locale === 'ja')

  /**
   * Initial State
   */
  readonly state = {
    showModal: false,
    userEmail: '',
    userPassword: '',
    termsAgreed: false,
    error: false,
    errorMessage: '',
    loading: false
  }

  /**
   * Constructor
   */
  constructor(props) {
    super(props)

    this.handleClick = this.handleClick.bind(this)
    this.handleClose = this.handleClose.bind(this)
    this.handleSubmit = this.handleSubmit.bind(this)
  }

  /**
   * Mound components
   */
  componentDidMount() {
    if (this.props.initOpenModal == true) {
      this.openModal()
    }
  }

  /**
   * Opens the modal
   */
  openModal() {
    this.lockScrolling()
    this.setState({ showModal: true })
  }

  /**
   * Closes the modal
   */
  closeModal() {
    this.unlockScrolling()
    this.setState({ showModal: false })
  }

  /**
   * Handles click on button that opens the modal
   */
  handleClick() {
    // Track click
    window.Analytics.track(
      'Clicked Sign Up Button', 
      { 
        subscription_name: this.props.subscriptionName,
        subscription_type: this.props.subscriptionType,
        path: window.location.pathname
      },
      {
        gtagSendto: window.Analytics.adwordsActionIds.clickedSignUpButton
      }
    )

    // Open modal
    this.openModal()
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
  async handleSubmit(event) {
    event.preventDefault()

    this.setState({
      error: false,
      errorMessage: '',
      loading: true
    })

    const urlParams = new URLSearchParams(window.location.search)

    const requestParams = {
      user: {
        email: this.state.userEmail,
        password: this.state.userPassword,
      },
      subscription_name: this.props.subscriptionName,
      subscription_type: this.props.subscriptionType,
      terms: this.state.termsAgreed,
      allow_promotion_codes: (urlParams.get('promo') != null) 
    }

    try {
      const response = await axios.post(
        `${this.props.signupUrl}.json`, 
        requestParams, 
        { headers: { 'Content-Type': 'application/json' } }
      )

      // Track checkout visit 
      window.Analytics.track(
        'Visited Checkout', 
        { 
          subscription_name: this.props.subscriptionName,
          subscription_type: this.props.subscriptionType,
          referrer: window.location.pathname
        },
        {
          gtagSendto: window.Analytics.adwordsActionIds.visitedCheckout
        }
      )

      // Redirect
      this.redirectToStripeCheckout(response.data.stripe_session_id)

    }
    catch(error) {
      this.setState({
        error: true,
        errorMessage: error.response.data.message,
        loading: false
      })
    }
  }

  /**
   * Redirects the user to Stripe Checkout
   */
  redirectToStripeCheckout = async (sessionId) => {
    const stripe = await stripePromise;
    const { error } = await stripe.redirectToCheckout({
      sessionId: sessionId
    });

    // If `redirectToCheckout` fails due to a browser or network
    // error, display the localized error message to your customer
    // using `error.message`.
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
   * Modal class names
   */
  modalClassName() {
    let classNames = ['signup-modal']
    if (this.state.loading) {
      classNames.push('signup-modal--loading')
    }
    return classNames.join(' ')
  }

  /**
   * Submit class names
   */
  submitClassName() {
    let classNames = ['btn', 'btn-primary', 'btn-block', 'signup-modal__submit']
    if (this.state.loading) {
      classNames.push('btn-disabled')
    }
    return classNames.join(' ')
  }

  translations(key: string) {
    if (!this.isJP) return key
    const items = {
      'Email Address:': 'メールドレス：',
      'Enter your email address': '＜メールアドレスを入力ください＞',
      'Password:': 'パスワード：',
      'Enter a secure password': '＜セキュアなパスワードを入力ください＞',
      'Create an Account': 'アカウントの作成',
      "After creating an account you will be redirected to our checkout process. If you're unhappy, we offer a 30-day money back guarantee.": 'アカウント作成後は、チェックアウトへリダイレクトされます。もしサービスにご満足いただけなかった場合は、30日間の返金保証をお付けしています。',
    }
    return items[key] ?? key
  } 


  /**
   * Render
   */
  render() {
    return (
      <>
        <button className={this.props.buttonClass} onClick={this.handleClick}>{this.props.buttonText}</button>
        <Modal
          isOpen={this.state.showModal}
          onRequestClose={this.handleClose}
          ariaHideApp={false}
          overlayClassName={this.modalClassName()}
          className="signup-modal__box"
        >
          <button className="signup-modal__close" onClick={this.handleClose}></button>
          <div className="signup-modal__body">
            <img src={this.props.logoUrl} className="signup-modal__logo" />
            { this.state.error &&
              <div className="alert alert-danger">{this.state.errorMessage}</div>
            }
            <form onSubmit={this.handleSubmit}>
              <div className="form-group">
                <label htmlFor="email" className="form-label">{this.translations('Email Address:')}</label>
                <input type="email" id="email" placeholder={this.translations("Enter your email address")} className="form-control" onChange={(e) => { this.setState({ userEmail: e.target.value }) }} />
              </div>

              <div className="form-group">
                <label htmlFor="password" className="form-label">{this.translations('Password:')}</label>
                <input type="password" id="password" placeholder={this.translations("Enter a secure password")} autoComplete="current-password" className="form-control" onChange={(e) => { this.setState({ userPassword: e.target.value }) }} />
              </div>

              <div className="form-group">
                <label htmlFor="terms" className="form-label">
                  <input type="checkbox" id="terms" required={true} checked={this.state.termsAgreed} onChange={(e) => { this.setState({ termsAgreed: e.target.checked }) }} /> {
                    this.isJP 
                      ? 
                      <>MailMateにサインアップすることで、MailMateの<a target="_blank" href={this.props.termsOfServiceUrl}>利用規約</a>に同意したことになります。</>
                      :
                      <>By signing up to MailMate.jp, you're agreeing to the MailMate <a target="_blank" href={this.props.termsOfServiceUrl}>Terms and Conditions</a>.</>
                  }
                </label>
              </div>

              <div className="form-group">
                <button type="submit" className={this.submitClassName()} disabled={this.state.loading}>
                  <span className="signup-modal__submit__text">{this.translations('Create an Account')}</span>
                  <span className="signup-modal__submit__spinner spinner-grow spinner-grow-sm" role="status" aria-hidden="true"></span>
                </button>
                <p className="signup-modal__info">{this.translations("After creating an account you will be redirected to our checkout process. If you're unhappy, we offer a 30-day money back guarantee.")}</p>
              </div>
            </form>
          </div>
        </Modal>
      </>
    )
  }
}
