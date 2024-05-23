/* Dependencies */
import * as React from 'react'
// import ReactGA from 'react-ga'

/* Props */
interface SideMenuProps {
  isAuthenticated: boolean,
  menuItems: Array<object>,
}

/* State */
interface SideMenuState {
  show: boolean // If to show the show side menu
}

/**
 * SideMenu
 * A menu, that comes from the side
 */
export default class SideMenu extends React.Component<SideMenuProps, SideMenuState> {
  /**
   * Attributes
   */
  triggerElements: Element[] = [] // Array holding the elements that act as triggers

  /**
   * Initial State
   */
  readonly state = { 
    show: false // Not showing by default
  }

  /**
   * Component Did Mount
   */
  componentDidMount() {
    // Add click listener to trigger elements
    document.querySelectorAll('[data-side-menu-trigger="true"]').forEach(element => {
      element.addEventListener('click', this.onSideMenuTriggerClick.bind(this))
      element.innerHTML = '<button class="hamburger hamburger--spin" type="button"><span class="hamburger-box"><span class="hamburger-inner"></span></span></button>'
      this.triggerElements.push(element)
    })
  }

  /**
   * Component Will Unmount
   */
  componentWillUnmount() {
    // Remove the click listener from trigger elements
    this.triggerElements.forEach(element => {
      element.removeEventListener('click', this.onSideMenuTriggerClick.bind(this))
    })
  }

  /**
   * Tracks a click in Google Analytics
   */
  trackClick(label) {
    // ReactGA.event({ category: 'Sidemenu', action: 'click', label: label })
  }

  /**
   * Render
   */
  render() {
    // If showing, stop body from scrolling, otherwise allow
    document.body.style.overflow = this.state.show ? 'hidden' : 'visible'

    // Calculate the top offset (when alerts are shwon this can change)
    let headerRect = document.getElementById('header').getBoundingClientRect()
    let topOffset = headerRect.top + headerRect.height
    let menuItems = this.props.menuItems

    // Return
    return (
      <>
        <div id="side-menu" className={`${this.state.show ? 'side-menu' : 'side-menu side-menu--hidden'}`} style={{top: topOffset}}>
          <div className="side_menuside-menu__primary">
            <div className="side-menu__item">
              <a href={menuItems['home']['url']} className="side-menu__item__link" onClick={e => this.trackClick(menuItems['home']['label'])}>{ menuItems['home']['label'] }</a>
            </div>
            <div className="side-menu__item">
              <a href={menuItems['about']['url']} className="side-menu__item__link" onClick={e => this.trackClick(menuItems['about']['label'])}>{ menuItems['about']['label'] }</a>
            </div>
            <div className="side-menu__item">
              <a href={menuItems['pricing']['url']} className="side-menu__item__link" onClick={e => this.trackClick(menuItems['pricing']['label'])}>{ menuItems['pricing']['label'] }</a>
            </div>
            {window.gon.locale !== 'ja' && (
              <div className="side-menu__item">
                <a href={menuItems['assistant']['url']} className="side-menu__item__link" onClick={e => this.trackClick(menuItems['assistant']['label'])}>{ menuItems['assistant']['label'] }</a>
              </div>
            )}
            <div className="side-menu__item">
              <a href={menuItems['blog']['url']} className="side-menu__item__link" onClick={e => this.trackClick(menuItems['blog']['label'])}>{ menuItems['blog']['label'] }</a>
            </div>
            <div className="side-menu__item">
              <a href={menuItems['faq']['url']} className="side-menu__item__link" onClick={e => this.trackClick(menuItems['faq']['label'])}>{ menuItems['faq']['label'] }</a>
            </div>
            <div className="side-menu__item">
              <a href={menuItems['service_directory']['url']} className="side-menu__item__link" onClick={e => this.trackClick(menuItems['service_directory']['label'])}>{ menuItems['service_directory']['label'] }</a>
            </div>
            {this.props.isAuthenticated &&
              <div className="side-menu__item">
                <a href={menuItems['sign_out']['url']} className="side-menu__item__link" data-method="delete" onClick={e => this.trackClick(menuItems['sign_out']['label'])}>{ menuItems['sign_out']['label'] }</a>
              </div>
            }
            {!this.props.isAuthenticated &&
              <>
                <div className="side-menu__item">
                  <a href={menuItems['sign_in']['url']} className="side-menu__item__link" onClick={e => this.trackClick(menuItems['sign_in']['label'])}>{ menuItems['sign_in']['label'] }</a>
                </div>
              </>
            }
          </div>
        </div>
      </>
    )
  }

  /**
   * Handler for when a trigger element is clicked
   * @param element the element being clicked
   */
  onSideMenuTriggerClick(element: any) {
    // If not showing, then show and toggle hamburger active class
    this.setState({show: !this.state.show}, () => {
      this.triggerElements.forEach(element => element.children[0].classList.toggle('is-active'))
    })
  }
}
