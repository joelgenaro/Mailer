// Dependencies
import * as React from 'react'
import * as Modal from 'react-modal'
import axios from 'axios'
import { DragDrop, newUploads } from '../drop_zone'
import Dropzone from 'react-dropzone'

// Props
interface NewTaskModalProps {
  isOpen: boolean,
  onClose: any,
  illustrationUrl: string,
  createTaskUrl: string
}

// State
interface NewTaskModalState {
  taskLabel: string,
  taskNotes: string,
  taskDueAtDate: string,
  taskDueAtTime: string,
  taskUploads: FileList,
  error: boolean,
  errorMessage: string,
  loading: boolean
}

/**
 * Range Slider
 */
export default class NewTaskModal extends React.Component<NewTaskModalProps, NewTaskModalState> {
  /**
   * Initial State
   */
  readonly state = {
    taskLabel: '',
    taskNotes: '',
    taskDueAtDate: '',
    taskDueAtTime: '',
    taskUploads: null,
    error: false,
    errorMessage: null,
    loading: false
  }

  /**
   * Constructor
   */
  constructor(props) {
    super(props)

    this.handleClose = this.handleClose.bind(this)
    this.handleSubmit = this.handleSubmit.bind(this)
  }

  /**
   * Handle updates to the component
   */
  componentDidUpdate(prevProps) {
    if (prevProps.isOpen == false && this.props.isOpen == true) {
      this.openModal()
    }
    if (prevProps.isOpen == true && this.props.isOpen == false) {
      this.closeModal()
    }
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
  }

  /**
   * Closes the modal
   */
  closeModal() {
    this.unlockScrolling()
    this.props.onClose.apply(this)
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
        notes: this.state.taskNotes,
        due_at: `${this.state.taskDueAtDate}T${this.state.taskDueAtTime}`,
        task_uploads_attributes: this.state.taskUploads
      }
    }
    const formData = new FormData();
    formData.append('task[label]', this.state.taskLabel);
    formData.append('task[notes]', this.state.taskNotes);
    formData.append('task[due_at]', `${this.state.taskDueAtDate}T${this.state.taskDueAtTime}`);
    this.state.taskUploads=newUploads
    if (this.state.taskUploads!=null)
    {
      Array.from(this.state.taskUploads).forEach(file => {
      console.log(file)
      formData.append('task[task_uploads_attributes][][file]',file as Blob);
      });
      
    }

    const requestHeaders = { headers: { 'Content-Type': 'multipart/form-data', 'Accept': 'application/json'} }
    const request = axios
      .post(this.props.createTaskUrl, formData, requestHeaders)
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
    let classNames = ['new-task-modal__overlay']
    if (this.state.loading) {
      classNames.push('new-task-modal__overlay--loading')
    }
    return classNames.join(' ')
  }

  /**
   * Submit class names
   */
  submitClassName() {
    let classNames = ['btn', 'btn-dark', 'btn-block', 'new-task-modal__submit']
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
      <Modal
        isOpen={this.props.isOpen}
        onRequestClose={this.handleClose}
        ariaHideApp={false}
        overlayClassName={this.modalOverlayClassName()}
        className="new-task-modal"
      >
        <button className="new-task-modal__close" onClick={this.handleClose}></button>
        <div className="new-task-modal__aside">
          <div className="new-task-modal__aside__inner">
            <img src={this.props.illustrationUrl} className="new-task-modal__illustration" />
            <h1 className="new-task-modal__title">Add a new task</h1>
            <p className="new-task-modal__subtitle">Enter details using this form, and your Virtual Assistant will complete the task for you.</p>
          </div>
        </div>
        <div className="new-task-modal__body">
          { this.state.error &&
            <div className="alert alert-danger">{this.state.errorMessage}</div>
          }
          <form onSubmit={this.handleSubmit}>
            <div className="form-group">
              <label htmlFor="label" className="form-label">What's the task?</label>
              <input type="text" id="label" placeholder="Book a restaurant for 9:30pm" className="form-control" onChange={(e) => { this.setState({ taskLabel: e.target.value }) }} />
            </div>

            <div className="form-group">
              <label htmlFor="due_at_date" className="form-label">When is it due?</label>
              <div className="new-task-modal__date-time">
                <input type="date" id="due_at_date" placeholder="Provide a due date" className="new-task-modal__date form-control" onChange={(e) => { this.setState({ taskDueAtDate: e.target.value }) }} />
                <input type="time" id="due_at_time" placeholder="11:00" className="new-task-modal__time form-control" onChange={(e) => { this.setState({ taskDueAtTime: e.target.value }) }} />
              </div>
            </div>

            <div className="form-group">
              <label htmlFor="label" className="form-label">Anything else to note?</label>
              <textarea id="label" placeholder="Add any other helpful notes here" className="form-control" onChange={(e) => { this.setState({ taskNotes: e.target.value }) }}></textarea>
            </div>
            <div className="form-group">
              <label htmlFor="label" className="form-label">Anything to upload?</label>
              <DragDrop/>
            </div>
            <div className="form-group">
              <button type="submit" className={this.submitClassName()} disabled={this.state.loading}>
                <span className="new-task-modal__submit__text">Create Task</span>
                <span className="new-task-modal__submit__spinner spinner-grow spinner-grow-sm" role="status" aria-hidden="true"></span>
              </button>
            </div>
          </form>
        </div>
      </Modal>
    );
  }
}
