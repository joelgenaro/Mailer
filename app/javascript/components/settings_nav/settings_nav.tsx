// Dependencies
import * as React from 'react'
import Sticky from 'react-stickynode'
import Dropdown from 'react-dropdown'
import 'react-dropdown/style.css'

// Props
interface SettingsNavProps {
  navLinks: Array<object>,
  activeNavLink: object,
  arrowIconSvg: string
}

// State
interface SettingsNavState {
  //
}

/**
 * Settings Nav
 */
export default class SettingsNav extends React.Component<SettingsNavProps, SettingsNavState> {
  /**
   * Initial State
   */
  readonly state = {
    //
  }

  /**
   * Component Did Mount
   */
  componentDidMount() {
    window.addEventListener('resize', this.handleWindowResize.bind(this))
  }

  /**
   * True if on mobile
   */
  isMobile() {
    return window.innerWidth < 992
  }

  /**
   * True if stick is enabled. False if not.
   */
  isSticky() {
    return ! this.isMobile()
  }

  /**
   * Navigation link classes
   */
  navClasses(link) {
    let classNames = ['settings__nav__link']
    // For Active Link
    if (link['url'] == this.props.activeNavLink || link['url'].split("/")[3] == JSON.stringify(this.props.activeNavLink).split("/")[3]) {
      classNames.push('settings__nav__link--active')
    }
    return classNames.join(' ')
  }

  /**
   * Handle window resize  by rerendering
   */
  handleWindowResize() {
    this.forceUpdate()
  }

  /**
   * Handles dropdown menu change
   */
  handleDropdownChange(event) {
    window.location.href = event.value
  }

  /**
   * Returns the current link
   */
  currentNavLink() {
    return this.props.navLinks.filter((link) => { return link['url'] == this.props.activeNavLink })[0]
  }

  /**
   * Renders the navigation links
   */
  buildNavLinks() {
    return this.props.navLinks.map((link, index) => {
      return (
        <a href={link['url']} key={index} className={this.navClasses(link)}>
          {link['label']}
          {(link['url']== this.props.activeNavLink || link['url'].split("/")[3] == JSON.stringify(this.props.activeNavLink).split("/")[3]) &&
            <span className="settings__nav__link__icon" dangerouslySetInnerHTML={{__html: this.props.arrowIconSvg}} />
          }
        </a>
      )
    })
  }

  /**
   * Renders the navigation dropdown (mobile)
   */
  buildNavDropdown() {
    const options = this.props.navLinks.map((link) => { return { label: link['label'], value: link['url'] } })
    const currentNavLink = this.currentNavLink()
    const defaultOption = { label: currentNavLink['label'], value: currentNavLink['url'] }

    return (<Dropdown options={options} onChange={this.handleDropdownChange} value={defaultOption} />);
  }

  /**
   * Render
   */
  render() {
    return (
      <div className="settings__nav__list">
        { this.isMobile() &&
          <>
            <h1 className="settings__nav__heading">Settings</h1>
            { this.buildNavDropdown() }
          </>
        }

        { ! this.isMobile() &&
          <Sticky enabled={this.isSticky()} top={50} bottomBoundary={1200}>
            { this.buildNavLinks() }
          </Sticky>
        }
      </div>
    )
  }
}
