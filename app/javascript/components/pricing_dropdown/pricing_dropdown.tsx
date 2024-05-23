// Dependencies
import * as React from 'react'
import { Manager, Reference, Popper } from 'react-popper'

// Props
interface PricingDropdownProps {
  text: string,
  className: string,
  assistantUrl: string,
  assistantIconUrl: string,
  mailUrl: string,
  mailIconUrl: string,
  downArrowIconUrl: string,
  rightArrowIconUrl: string
}

// State
interface PricingDropdownState {
  isShowing: boolean
}

/**
 * Pricing Dropdown
 */
export default class PricingDropdown extends React.Component<PricingDropdownProps, PricingDropdownState> {
  popoverRef: React.RefObject<any> = React.createRef() // The popover element
  buttonRef: React.RefObject<any> = React.createRef() // The button element

  /**
   * Initial State
   */
  readonly state = { 
    isShowing: false
  }

  /**
   * Component Did Mount
   */
  componentDidMount() {
    this.addOutsideClickHandlers()
  }

  /**
   * Component Will Unmount
   */
  componentWillUnmount() {
    this.removeOutsideClickHandlers()
  }

  /**
   * Method for showing (or hiding) the popover. 
   * Also adds the listeners for outside clicks
   *
   * @param show if to show or hide the popover
   */
  togglePopover(show = true) {
    if (show) {
      this.addOutsideClickHandlers()
    } else {
      this.removeOutsideClickHandlers()
    }

    // Toggle the popover element
    this.setState({ isShowing: show })
  }

  /**
   * Adds the outside click handlers
   * 
   * @param add if to add the outside click handlers
   */
  addOutsideClickHandlers() {
    if ('ontouchend' in window) {
      document.addEventListener('touchend', this.handleOutsideClick.bind(this))
    } else {
      document.addEventListener('click', this.handleOutsideClick.bind(this))
    }
  }

  /**
   * Removes the outside click handlers
   */
  removeOutsideClickHandlers() {
    document.removeEventListener('touchend', this.handleOutsideClick.bind(this))
    document.removeEventListener('click', this.handleOutsideClick.bind(this))
  }

  /**
   * Handles when there is an outside click, checking if
   * it is actually outside (not on the button or popover), 
   * and closing the popover if so
   * 
   * @param event the click event
   */
  handleOutsideClick(event) {
    if (this.state.isShowing) {
      // Ignore Button Clicks 
      if (this.buttonRef.current.contains(event.target)) {
        return 
      }
      // Ignore Popover Clicks 
      else if (this.popoverRef.current.contains(event.target)) {
        return 
      }
      // Otherwise clicked outside, so close 
      else {
        this.setState({ isShowing: false })
      }
    }
  }

  /**
   * Renders the dropdown
   */
  buildDropdown() {
    return (
      <div className="pricing-dropdown__dropdown">
        <a href={this.props.assistantUrl} className="pricing-dropdown__link">
          <span className="pricing-dropdown__left">
            <span className="pricing-dropdown__icon pricing-dropdown__icon--assistant">
              <img src={this.props.assistantIconUrl} />
            </span>
          </span>
          <span className="pricing-dropdown__right">
            <span className="pricing-dropdown__label">Assistant</span>
            <span className="pricing-dropdown__text">Competent, bilingual, virtual assistants immediately available in Japan.</span>
          </span>
          <img src={this.props.rightArrowIconUrl} className="pricing-dropdown__arrow" />
        </a>
        <a href={this.props.mailUrl} className="pricing-dropdown__link">
          <span className="pricing-dropdown__left">
            <span className="pricing-dropdown__icon pricing-dropdown__icon--mail">
              <img src={this.props.mailIconUrl} />
            </span>
          </span>
          <span className="pricing-dropdown__right">
            <span className="pricing-dropdown__label">Mail</span>
            <span className="pricing-dropdown__text">We receive your mail. Scan it. Translate it. Store it. You can read it from anywhere.</span>
          </span>
          <img src={this.props.rightArrowIconUrl} className="pricing-dropdown__arrow" />
        </a>
      </div>
    )
  }

  /**
   * Render
   */
  render() {
    return (
      <div className="pricing-dropdown">
        <Manager>
          <Reference innerRef={this.buttonRef}>
            {({ ref }) => (
              <a href="#" ref={ref} onClick={(e) => { e.preventDefault(); this.togglePopover(!this.state.isShowing)}} className={this.props.className}>
                {this.props.text}
                <span className="pricing-dropdown__link-arrow">
                  <img src={this.props.downArrowIconUrl} />
                </span>
              </a>
            )}
          </Reference>

          { this.state.isShowing && 
            <Popper 
              placement="bottom-start"
              innerRef={this.popoverRef}
            >
              {({ ref, style, placement, arrowProps}) => (
                <div ref={ref} style={style} data-placement={placement} className="pricing-dropdown__popper">
                  {this.buildDropdown()}
                  
                  {/* Arrow */}
                  <div ref={arrowProps.ref} style={arrowProps.style}  data-placement={placement} className="pricing-dropdown__popper-arrow"/>
                </div>
              )}
            </Popper>
          }
        </Manager>
      </div>
    )
  }
}
