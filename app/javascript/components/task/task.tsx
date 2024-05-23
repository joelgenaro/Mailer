// Dependencies
import * as React from 'react'
import * as Modal from 'react-modal'
import axios from 'axios'

// Props
interface EditTaskButtonProps {
  createTaskUrl: string
}

// State
interface EditTaskButtonState {
  showModal: boolean,
  taskLabel: string,
  taskDueAt: string,
  taskRequestBy: string,
  error: boolean,
  errorMessage: string,
  loading: boolean
}

/**
 * Range Slider
 */
export default class EditTaskButton extends React.Component<EditTaskButtonProps, EditTaskButtonState> {
  /**
   * Initial State
   */
  readonly state = {
    showModal: false,
    taskLabel: '',
    taskDueAt: '',
    taskRequestBy: '',
    error: false,
    errorMessage: null,
    loading: false
  }

  /**
   * Constructor
   */
  constructor(props) {
    super(props)

    this.handleClick = this.handleClick.bind(this)
    this.handleClose = this.handleClose.bind(this)
    this.handleSubmit = this.handleSubmit.bind(this)
  }

  /**
   * Locks window scrolling
   */
  lockScrolling() {
    document.body.classList.add('lock-scrolling')
  }

  /**
   * Unlock window scrolling
   */
  unlockScrolling() {
    document.body.classList.remove('lock-scrolling')
  }

  /**
   * Opens the modal
   */
  openModal() {
    this.lockScrolling()
    this.setState({ showModal: true })
  }

  /**
   * Closes the modal
   */
  closeModal() {
    this.unlockScrolling()
    this.setState({ showModal: false })
  }

  /**
   * Handles click on button that opens the modal
   */
  handleClick() {
    this.openModal()
  }

  /**
   * Handles close button click
   */
  handleClose() {
    this.closeModal()
  }

  /**
   * Handles form submit
   */
  handleSubmit(event) {
    event.preventDefault()

    this.setState({
      error: false,
      errorMessage: '',
      loading: true
    })

    const requestParams = {
      task: {
        label: this.state.taskLabel,
        due_at: this.state.taskDueAt,
        request_by: this.state.taskRequestBy
      }
    }
    const requestHeaders = { headers: { 'Content-Type': 'application/json' } }
    const request = axios
      .post(`${this.props.createTaskUrl}.json`, requestParams, requestHeaders)
      .then(response => {
        window.location.href = response.data.redirect_to
      }).catch(error => {
        this.setState({
          error: true,
          errorMessage: error.response.data.message,
          loading: false
        })
      })
  }

  /**
   * Modal overlay class names
   */
  modalOverlayClassName() {
    let classNames = ['edit-task__modal-overlay']
    if (this.state.loading) {
      classNames.push('edit-task__modal-overlay--loading')
    }
    return classNames.join(' ')
  }

  /**
   * Submit class names
   */
  submitClassName() {
    let classNames = ['btn', 'btn-white', 'btn-block', 'edit-task__submit']
    if (this.state.loading) {
      classNames.push('btn-disabled')
    }
    return classNames.join(' ')
  }

  /**
   * Render
   */
  render() {
    return (
      <div className="task">
      </div>
    );
  }
}
