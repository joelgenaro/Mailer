import React from 'react'
import Box from '../design-system/box'
import Text from '../design-system/text'
import GenericModal from '../generic_modal'
import { Range, getTrackBackground } from 'react-range'
import styled from 'styled-components'
import routes from '../../src/lib/routes'
import _ from 'lodash'
import { APIMessageError, client, messageForApolloErrorType, typeForApolloError } from '../../src/apollo'
import { ASSISTANT_PURCHASE_ADDITIONAL_TIME_MUTATION } from '../../src/graphql/mutations'
import humanizeDuration from 'humanize-duration'

interface AssistantPurchaseAdditionalTimeButtonAndModalProps {
  additionalTimePurchasable: number,
  costPerMinute: number,
  plan: any,
  paymentCardType: string,
  paymentCardLast4: string
}

interface AssistantPurchaseAdditionalTimeButtonAndModalState {
  modalIsOpen: boolean,
  timeSelectorValue: number,
  isLoading: boolean,
  errorMessage?: string,
  successMessage?: string
}

/**
 * A button that shows a modal for purchasing additional time, 
 * for use in Assistant part of the app 
 */
export default class AssistantPurchaseAdditionalTimeButtonAndModal extends React.Component<AssistantPurchaseAdditionalTimeButtonAndModalProps, AssistantPurchaseAdditionalTimeButtonAndModalState> {
  timeSelectorMaxValue = this.props.additionalTimePurchasable
  timeSelectorMinValue = (this.timeSelectorMaxValue === 10) ? 0 : 10 // Handle if only 10 minutes available
  timeSelectorStep = 10 // 10 minute steps

  readonly state: AssistantPurchaseAdditionalTimeButtonAndModalState = {
    modalIsOpen: false,
    timeSelectorValue: this.timeSelectorMaxValue,
    isLoading: false,
    errorMessage: undefined
  }

  render() {
    const planTitle = this.props.plan.title
    const additionalTimePurchasable = this.props.plan.configuration.additional_minutes_purchasable
    const additionalTimePurchasedSoFar = additionalTimePurchasable - this.props.additionalTimePurchasable

    return (
      <>
        {/* Button */}
        <button 
          onClick={() => this.setState({ modalIsOpen: true })} 
          className="btn btn-dark"
        >
          + Purchase additional time  
        </button>

        {/* Modal */}
        <GenericModal
          isOpen={this.state.modalIsOpen}
          onRequestClose={() => !this.state.isLoading ? this.setState({ modalIsOpen: false }) : undefined}
          shouldCloseOnEsc={!this.state.isLoading}
          shouldCloseOnOverlayClick={!this.state.isLoading}
          showCloseButton={!this.state.isLoading}
        >
          {/* Heading */}
          <Box display="flex" flexDirection="column" mb="3">
            <Text fontSize="28px" fontWeight="600" color="#2b3035" mb={1}>
              Purchase Additional Time
            </Text>
            <Text fontSize="14px" fontWeight="400" color="#737670">
              Your plan ({planTitle}) can purchase up to an additional {this.humanizeMinutes(additionalTimePurchasable)} per month. You've purchased {additionalTimePurchasedSoFar === 0 ? 'no additional time' : this.humanizeMinutes(additionalTimePurchasedSoFar)} so far this month. 
              Additional time will be added to your account for 30 days from today.
            </Text>
          </Box>

          {/* Time Selector */}
          <Box border="1px solid #eee" borderRadius="4px" padding="15px">
            {/* Value */}
            <Box display="flex" flexDirection="column" mb="2">
              <Text fontSize="22px" fontWeight="500" color="#2b3035">
                {this.state.timeSelectorValue === 0 && (<>Select time</>)} 
                {this.state.timeSelectorValue !== 0 && (<>{this.humanizeMinutes(this.state.timeSelectorValue)} for {this.purchaseAmountDisplay()}</>)}
              </Text>
            </Box>

            {/* Range */}
            <Range
              step={this.timeSelectorStep}
              min={this.timeSelectorMinValue}
              max={this.timeSelectorMaxValue}
              values={[this.state.timeSelectorValue]}
              onChange={(values) => this.setState({ timeSelectorValue: values[0] })}
              disabled={this.state.isLoading}
              renderMark={({ props, index }) => (
                <div
                  {...props}
                  style={{ ...props.style, height: '8px', width: '8px', borderRadius: '12px', backgroundColor: index * this.timeSelectorStep <  this.state.timeSelectorValue ? '#48AC98' : '#C8CDD5' }} 
                />
              )}    
              renderTrack={({ props, children }) => (
                <div
                  onMouseDown={props.onMouseDown}
                  onTouchStart={props.onTouchStart}
                  style={{ ...props.style, height: '36px', display: 'flex', width: '100%' }}
                >
                  <div
                    ref={props.ref}
                    style={{ height: '4px', width: '100%', borderRadius: '4px', alignSelf: 'center', background: getTrackBackground({ values: [ this.state.timeSelectorValue ], colors: ['#48AC98', '#C8CDD5'], min: this.timeSelectorMinValue, max: this.timeSelectorMaxValue }) }}
                  >
                    {children}
                  </div>
                </div>
              )}
              renderThumb={({ props, isDragged }) => (
                <div
                  {...props}
                  style={{ ...props.style, height: '28px', width: '28px', borderRadius: '28px', backgroundColor: '#FFF', display: 'flex', justifyContent: 'center', alignItems: 'center', boxShadow: '0px 2px 6px #AAA' }}
                >
                  <div style={{ height: '12px', width: '12px', borderRadius: '12px', backgroundColor: isDragged ? '#48AC98' : '#FFF' }} />
                </div>
              )}
            />
          </Box>

          {/* Payment Card */}
          <PaymentCard>
            <h5>Payment Card</h5>
            <span>💳 {this.props.paymentCardType} ending **** **** **** {this.props.paymentCardLast4}</span>
            <a href={routes.settingsBilling}>Change</a>
          </PaymentCard>

          {/* Error Message */}
          {this.state.errorMessage && 
            <Box borderRadius="4px" backgroundColor="#FED7D2" p="2" mb="2">
              <Text color="#863734">{this.state.errorMessage}</Text>
            </Box>
          }

          {/* Success Message */}
          {this.state.successMessage && 
            <Box borderRadius="4px" backgroundColor="#E8F4F2" p="2" mb="2">
              <Text color="#2B675B">{this.state.successMessage}</Text>
            </Box>
          }

          {/* Purchase Button */}
          <button
            className="btn btn-dark btn-block"
            onClick={this.submit.bind(this)}
            disabled={this.state.isLoading || this.state.timeSelectorValue === 0}
          >
            {this.state.isLoading ? 'Loading...' : 'Confirm Purchase'}
          </button>
        </GenericModal>
      </>
    )
  }

  // MARK: Data Wrangling

  humanizeMinutes(minutes: number) {
    return humanizeDuration((minutes * 60) * 1000, { conjunction: " and " })
  }
  
  purchaseAmount() {
    // This logic should match Assistant::Services::PurchaseAdditionalTime#purchase_amount
    return _.round(this.state.timeSelectorValue * this.props.costPerMinute)
  }

  purchaseAmountDisplay() {
    return `¥${this.purchaseAmount().toLocaleString()}`
  }

  // MARK: API

  async submit() {
    // Confirm purchase
    if (!confirm(`Are you sure? Your card will now be charged for ${this.purchaseAmountDisplay()}`)) {
      return
    }

    // Show loading and clear error message
    this.setState({ isLoading: true, errorMessage: undefined })

    try {
      let response = await client.mutate({
        mutation: ASSISTANT_PURCHASE_ADDITIONAL_TIME_MUTATION,
        variables: { input: {
          minutes: this.state.timeSelectorValue,
          purchaseAmountShown: this.purchaseAmount()
        }}
      })

      // Error 
      if (response.data.assistantPurchaseAdditionalTime.errorMessage) {
        throw new APIMessageError(response.data.assistantPurchaseAdditionalTime.errorMessage)
      }

      // Success
      this.setState({ successMessage: "Successfully purchased additional time, reloading..." })
      window.location.reload()
    }
    catch(error) {
      let errorMessage = (error instanceof APIMessageError) ? error.message : messageForApolloErrorType(typeForApolloError(error))
      this.setState({ isLoading: false, errorMessage: errorMessage })
    }
  }
}

const PaymentCard = styled.div`
  padding: 25px 15px 15px 15px;
  border: 1px solid #eee;
  border-radius: 4px;
  text-align: left;
  margin: 30px 0;
  position: relative;
  display: flex;
  align-items: center;

  h5 {
    position: absolute;
    top: -20px;
    left: 5px;
    background: #fff;
    padding: 10px;
  }

  span {
    flex-grow: 1;
  }

  a {
    font-size: 85%;
    color: #48AC98;
  }
`