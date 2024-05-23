// Dependencies
import * as React from 'react'
import EditTaskModal from '../edit_task_modal'

// Props
interface EditTaskButtonProps {
  buttonText: string,
  buttonClass: string,
  taskLabel: string,
  taskNotes: string,
  taskDueAtTime: string,
  taskDueAtDate: string,
  taskUploads: FileList,
  editTaskUrl: string,
  deleteTaskUrl: string
}

// State
interface EditTaskButtonState {
  showModal: boolean
}

/**
 * Range Slider
 */
export default class EditTaskButton extends React.Component<EditTaskButtonProps, EditTaskButtonState> {
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
        <EditTaskModal
          isOpen={this.state.showModal}
          taskLabel={this.props.taskLabel}
          taskNotes={this.props.taskNotes}
          taskDueAtTime={this.props.taskDueAtTime}
          taskDueAtDate={this.props.taskDueAtDate}
          taskUploads={this.props.taskUploads}
          onClose={() => { this.setState({ showModal: false }) }}
          editTaskUrl={this.props.editTaskUrl}
          deleteTaskUrl={this.props.deleteTaskUrl}
        />
      </>
    );
  }
}
