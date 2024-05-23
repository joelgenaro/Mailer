// Dependencies
import * as React from 'react'
import BuySubscriptionModal from '../buy_subscription_modal'

// Props
interface BuySubscriptionButtonProps {
  buttonText: string,
  buttonClass: string,
  subscriptionName: string,
  paymentAmount: string,
  paymentDescription: string,
  paymentCardType: string,
  paymentCardLast4: string
  illustrationUrl: string,
  changeCardUrl: string,
  checkoutUrl: string
}

// State
interface BuySubscriptionButtonState {
  showModal: boolean
}

/**
 * Pay Button
 */
export default class BuySubscriptionButton extends React.Component<BuySubscriptionButtonProps, BuySubscriptionButtonState> {
  /**
   * Initial State
   */
  readonly state = {
    showModal: false
  }

  /**
   * Render
   */
  render() {
    return (
      <>
        <button onClick={() => { this.setState({ showModal: true }) }} className={this.props.buttonClass}>{ this.props.buttonText }</button>
        <BuySubscriptionModal
          isOpen={this.state.showModal}
          onClose={() => { this.setState({ showModal: false }) }}
          subscriptionName={this.props.subscriptionName}
          paymentAmount={this.props.paymentAmount}
          paymentDescription={this.props.paymentDescription}
          paymentCardType={this.props.paymentCardType}
          paymentCardLast4={this.props.paymentCardLast4}
          illustrationUrl={this.props.illustrationUrl}
          changeCardUrl={this.props.changeCardUrl}
          checkoutUrl={this.props.checkoutUrl}
        />
      </>
    )
  }
}
