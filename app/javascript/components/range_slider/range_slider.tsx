// Dependencies
import * as React from 'react'
import InputRange from 'react-input-range'
import 'react-input-range/lib/css/index.css'
import NumberFormat from 'react-number-format'

// Props
interface RangeSliderProps {
  mode: string,
  inputId: string,
  inputName: string,
  defaultValue: number,
  step: number,
  minValue: number,
  maxValue: number,
  currencySymbol: string,
  maxValueIsUnlimited: boolean // If to show 'No Limit' when max value reached
}

// State
interface RangeSliderState {
  value: any
}

/**
 * Range Slider
 */
export default class RangeSlider extends React.Component<RangeSliderProps, RangeSliderState> {
  /**
   * Constructor
   */
  constructor(props) {
    super(props)

    this.state = {
      value: this.props.defaultValue
    }
  }

  /**
   * Returns the formatted value
   *
   * @param  {number} value
   * @return {number|string}
   */
  formattedValue(value) {
    if (this.props.mode == 'currency') {
      return (<NumberFormat value={value} displayType={'text'} thousandSeparator={true} prefix={this.props.currencySymbol} />)
    } else {
      return value
    }
  }

  /**
   * Render
   */
  render() {
    return (
      <div className="range-slider">
        <input type="hidden" name={this.props.inputName} id={this.props.inputId} value={this.state.value} />
        <InputRange
          maxValue={this.props.maxValue}
          minValue={this.props.minValue}
          step={this.props.step}
          value={this.state.value}
          formatLabel={value => {
            // If for the max limit, should show 'No Limit',
            // ie for Jonathan and his mail bills. Have to 
            // do the checking and handling of 'no limit' in
            // backend code still though (ie will still return,
            // whatever the max limit value is). See more here:
            // doc/auto_paying_bills.md (for also if have to change)
            if (value < this.props.maxValue) {
              return this.formattedValue(value)
            } else {
              if (this.props.maxValueIsUnlimited) {
                return window.gon.locale === 'ja' ? '上限なし' : 'No Limit'
              } 
              else {
                return this.formattedValue(value)
              }
            }
          }}
          onChange={value => this.setState({ value })} />
      </div>
    );
  }
}
