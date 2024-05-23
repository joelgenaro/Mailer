// Dependencies
import * as React from 'react'

// Props
interface LoaderProps {
  isLoading: boolean
}

// State
interface LoaderState {
  //
}

/**
 * Loader
 */
export default class Loader extends React.Component<LoaderProps, LoaderState> {
  /**
   * Initial State
   */
  readonly state = {
    isLoading: false
  }

  /**
   * Class names
   */
  classNames() {
    return "loader loader-md"
  }

  /**
   * Render
   */
  render() {
    return (
      <div className={this.classNames()}>
        <div></div>
        <div></div>
        <div></div>
      </div>
    );
  }
}
