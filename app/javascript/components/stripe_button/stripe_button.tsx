// Dependencies
import * as React from 'react'
import * as ReactDOM from 'react-dom'
import axios from 'axios'
import { loadStripe } from '@stripe/stripe-js'

// Environment Variables
declare const gon: any

// Make sure to call `loadStripe` outside of a component’s render to avoid
// recreating the `Stripe` object on every render.
const stripePromise = loadStripe(gon.stripe_publishable_key);

// Props
interface StripeButtonProps {
  mode: string,
  buttonText: string,
  buttonClass: string,
  subscriptionName: string,
  subscriptionType: string,
  checkoutUrl: string,
  userEmail: string
}

// State
interface StripeButtonState {
  //
}

/**
 * Stripe Button
 */
export default class StripButton extends React.Component<StripeButtonProps, StripeButtonState> {
  /**
   * Constructor
   */
  constructor(props) {
    super(props)

    this.handleClick = this.handleClick.bind(this)
  }

  /**
   * Handles button click, redirecting the user to Stripe Checkout
   */
  handleClick = async (event) => {
    event.preventDefault();

    const requestHeaders = { headers: { 'Content-Type': 'application/json' } }
    const request = axios
      .post(`${this.props.checkoutUrl}.json`, this.requestParams(), requestHeaders)
      .then(response => {
        this.redirectToStripeCheckout(response.data.stripe_session_id)
      }).catch(error => {
        console.log(error)
      })
  }

  /**
   * The Stripe request params
   */
  requestParams() {
    let requestParams = {
      user: { email: this.props.userEmail }
    }

    // Show promotion code
    const urlParams = new URLSearchParams(window.location.search)
    requestParams['allow_promotion_codes'] = (urlParams.get('promo') != null)

    // Subscription specific stuff
    if (this.props.mode == 'subscription') {
      requestParams['subscription_name'] = this.props.subscriptionName;
      requestParams['subscription_type'] = this.props.subscriptionType;
    }

    return requestParams;
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
   * Render
   */
  render() {
    return (
      <button role="link" onClick={this.handleClick} className={this.props.buttonClass}>{this.props.buttonText}</button>
    )
  }
}
