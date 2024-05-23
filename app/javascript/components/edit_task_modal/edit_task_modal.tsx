// Dependencies
import * as React from 'react'
import * as Modal from 'react-modal'
import axios from 'axios'
import { DragDrop, newUploads } from '../drop_zone'
import { object } from 'prop-types'
import { Listbox } from '@headlessui/react'

function PreviousUploads({uploads})
  {   
    const list=[]
    if (uploads.length>0)
    {
      list.push(<h6>Previous Uploads</h6>)
      uploads.forEach(upload => {
        list.push(<li key={upload.file_file_name}>
          {upload.file_file_name} on {upload.updated_at}
         </li>)
      });
    }
      return (<div>{list}</div>)
  }
// Props
interface EditTaskModalProps {
  isOpen: boolean,
  onClose: any,
  taskLabel: string,
  taskNotes: string,
  taskDueAtDate: string,
  taskDueAtTime: string,
  editTaskUrl: string,
  deleteTaskUrl: string,
  taskUploads: FileList
}

// State
interface EditTaskModalState {
  currentTaskLabel: string,
  currentTaskNotes: string,
  currentTaskDueAtTime: string,
  currentTaskDueAtDate: string,
  currentTaskUploads: FileList,
  error: boolean,
  errorMessage: string,
  loading: boolean
}

/**
 * Range Slider
 */
export default class EditTaskModal extends React.Component<EditTaskModalProps, EditTaskModalState> {
  /**
   * Initial State
   */
  readonly state = {
    currentTaskLabel: '',
    currentTaskNotes: '',
    currentTaskDueAtTime: '',
    currentTaskDueAtDate: '',
    currentTaskUploads: null,
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
   * Component did mount
   */
  componentDidMount() {
    this.setState({
      currentTaskLabel: this.props.taskLabel,
      currentTaskNotes: this.props.taskNotes,
      currentTaskDueAtTime: this.props.taskDueAtTime,
      currentTaskDueAtDate: this.props.taskDueAtDate,
      currentTaskUploads: this.props.taskUploads,
    })
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
        label: this.state.currentTaskLabel,
        notes: this.state.currentTaskNotes,
        due_at: `${this.state.currentTaskDueAtDate}T${this.state.currentTaskDueAtTime}`,
        task_uploads_attributes: [{
          file: this.state.currentTaskUploads[0]
        }]
      }
    }

    const formData = new FormData();
    formData.append('task[label]', this.state.currentTaskLabel);
    formData.append('task[notes]', this.state.currentTaskNotes);
    formData.append('task[due_at]', `${this.state.currentTaskDueAtDate}T${this.state.currentTaskDueAtTime}`);
    this.state.currentTaskUploads=newUploads
    if (this.state.currentTaskUploads!=null)
    {
      Array.from(this.state.currentTaskUploads).forEach(file => {
      if(!file.hasOwnProperty('id'))
      {
        formData.append('task[task_uploads_attributes][][file]',file as Blob);
      }
      });
      
    }
    
    formData.append('_method','PATCH')
    const requestHeaders = { headers: { 'Content-Type': 'multipart/form-data', 'Accept': 'application/json'} }
    const request = axios
      .post(this.props.editTaskUrl, formData, requestHeaders)
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
    let classNames = ['edit-task-modal__overlay']
    if (this.state.loading) {
      classNames.push('edit-task-modal__overlay--loading')
    }
    return classNames.join(' ')
  }

  /**
   * Submit class names
   */
  submitClassName() {
    let classNames = ['btn', 'btn-dark', 'btn-block', 'edit-task-modal__submit']
    if (this.state.loading) {
      classNames.push('btn-disabled')
    }
    return classNames.join(' ')
  }

  /**
   * Deelte class names
   */
  deleteClassName() {
    let classNames = ['btn', 'btn-danger', 'btn-block', 'edit-task-modal__delete']
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
        className="edit-task-modal"
      >
        <button className="edit-task-modal__close" onClick={this.handleClose}></button>
        <div className="edit-task-modal__body">
          <h1 className="edit-task-modal__title">Edit task</h1>
          { this.state.error &&
            <div className="alert alert-danger">{this.state.errorMessage}</div>
          }
          <form onSubmit={this.handleSubmit}>
            <div className="form-group">
              <label htmlFor="label" className="form-label">What's the task?</label>
              <input type="text" id="label" placeholder="Book a restaurant for 9:30pm" className="form-control" defaultValue={this.props.taskLabel} onChange={(e) => { this.setState({ currentTaskLabel: e.target.value }) }} />
            </div>

            <div className="form-group">
              <label htmlFor="due_at" className="form-label">When is it due?</label>
              <div className="edit-task-modal__date-time">
                <input type="date" id="due_at_date" placeholder="Provide a due date" className="edit-task-modal__date form-control" defaultValue={this.state.currentTaskDueAtDate} onChange={(e) => { this.setState({ currentTaskDueAtDate: e.target.value }) }} />
                <input type="time" id="due_at_time" placeholder="11:00" className="edit-task-modal__time form-control" defaultValue={this.state.currentTaskDueAtTime} onChange={(e) => { this.setState({ currentTaskDueAtTime: e.target.value }) }} />
              </div>
            </div>

            <div className="form-group">
              <label htmlFor="label" className="form-label">Anything else to note?</label>
              <textarea id="label" placeholder="Add any other helpful notes here" className="form-control" defaultValue={this.state.currentTaskNotes} onChange={(e) => { this.setState({ currentTaskNotes: e.target.value }) }}></textarea>
            </div>
            <div className="form-group">
              {this.state.currentTaskUploads && <PreviousUploads uploads={this.props.taskUploads}/>}
            </div>
            <div className="form-group">
              <label htmlFor="label" className="form-label">Anything to upload?</label>
              <DragDrop/>
            </div>

            <div className="form-group edit-task-modal__actions">
              <button type="submit" className={this.submitClassName()} disabled={this.state.loading}>
                <span className="edit-task-modal__submit__text">Update Task</span>
                <span className="edit-task-modal__submit__spinner spinner-grow spinner-grow-sm" role="status" aria-hidden="true"></span>
              </button>
              <a href={this.props.deleteTaskUrl} className={this.deleteClassName()} data-confirm="Are you sure you want to delete this task? This cannot be reversed." data-method="delete">
                <span className="edit-task-modal__delete__text">Delete Task</span>
              </a>
            </div>
          </form>
        </div>
      </Modal>
    );
  }
}

