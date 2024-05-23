// Dependencies
import * as React from 'react'
import NewTaskModal from '../new_task_modal'

// Props
interface NewTaskButtonProps {
  buttonText: string,
  buttonClass: string,
  illustrationUrl: string,
  createTaskUrl: string
}

// State
interface NewTaskButtonState {
  showModal: boolean
}

/**
 * Range Slider
 */
export default class NewTaskButton extends React.Component<NewTaskButtonProps, NewTaskButtonState> {
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
        <NewTaskModal
          isOpen={this.state.showModal}
          onClose={() => { this.setState({ showModal: false }) }}
          illustrationUrl={this.props.illustrationUrl}
          createTaskUrl={this.props.createTaskUrl}
        />
      </>
    );
  }
}
