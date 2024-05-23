// Dependencies
import * as React from 'react'
import PayBillModal from '../pay_bill_modal'

// Props
interface PayBillButtonProps {
  buttonText: string,
  buttonClass: string,
  paymentAmount: string,
  paymentDescription: string,
  paymentCardType: string,
  paymentCardLast4: string
  changeCardUrl: string,
  checkoutUrl: string
}

// State
interface PayBillButtonState {
  showModal: boolean
}

/**
 * Pay Button
 */
export default class PayBillButton extends React.Component<PayBillButtonProps, PayBillButtonState> {
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
        <PayBillModal
          isOpen={this.state.showModal}
          onClose={() => { this.setState({ showModal: false }) }}
          paymentAmount={this.props.paymentAmount}
          paymentDescription={this.props.paymentDescription}
          paymentCardType={this.props.paymentCardType}
          paymentCardLast4={this.props.paymentCardLast4}
          changeCardUrl={this.props.changeCardUrl}
          checkoutUrl={this.props.checkoutUrl}
        />
      </>
    )
  }
}
