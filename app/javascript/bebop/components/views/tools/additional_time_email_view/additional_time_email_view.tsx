import { DateTime } from "luxon"
import React from "react"
import Select, { OptionTypeBase } from "react-select"
import { ASSISTANT_TASKS, USERS } from "../../../../graphql/queries";
import { APIMessageError, client, messageForApolloErrorType, typeForApolloError } from "../../../../lib/apollo"
import ImageMailLogo from './assets/mail-logo.png'
import { CheckCircleIcon, MailIcon, XCircleIcon } from '@heroicons/react/solid'
import { IAssistantTask, IUser } from '../../../../graphql/types'
import { SEND_ADDITIONAL_TIME_EMAIL_MUTATION } from "../../../../graphql/mutations"
import _ from "lodash"
import prettyMilliseconds from 'pretty-ms'
import Dialog from "../../../design-system/dialog";


interface AdditionalTimeEmailViewProps {
  
}

interface AdditionalTimeEmailViewState {
  isLoading: boolean,
  errorMessage?: string,
  customerOptions: OptionTypeBase[],
  taskOptions: OptionTypeBase[],

  formCustomerOption?: OptionTypeBase,
  formTaskOption: OptionTypeBase,
  formTimeRequired: string,
  formCostPerMinute: string,
  formMessage: string

  showSuccessDialog: boolean
}

export default class AdditionalTimeEmailView extends React.Component<AdditionalTimeEmailViewProps, AdditionalTimeEmailViewState> {
  fetchedUsers?: IUser[]
  fetchedTasks?: IAssistantTask[]

  readonly state: AdditionalTimeEmailViewState = {
    isLoading: true,
    errorMessage: undefined,
    customerOptions: [],
    taskOptions: [],

    formCustomerOption: undefined,
    formTaskOption: undefined,
    formTimeRequired: "",
    formCostPerMinute: "",
    formMessage: 'In order to complete your task "{{task}}", you require an additional {{time}} for {{cost}}. Please purchase the additional time in order to complete your task and avoid delays.',

    showSuccessDialog: false
  }

  componentDidMount() {
    this.fetchUsers()
  }

  render() {  
    let totalCost = "..."
    if (parseInt(this.state.formTimeRequired) && parseInt(this.state.formCostPerMinute)) {
      totalCost = "¥" + (parseInt(this.state.formTimeRequired) * parseInt(this.state.formCostPerMinute)).toLocaleString('en')
    }

    return (
      <div className="w-full h-screen flex">
        {/* Form */}
        { this.renderForm(totalCost) }

        {/* Preview */}
        { this.renderPreview(totalCost) }

        {/* Success Dialog */}
        <SuccessDialog 
          isOpen={this.state.showSuccessDialog}
        />
      </div>
    )
  }

  renderForm(totalCost: string) {
    return (
      <div className="flex flex-1 flex-col h-full px-4">
        {/* Error Message */}
        {this.state.errorMessage && (
          <div className="rounded-md bg-red-50 p-4 border border-red-200 mt-5">
            <div className="flex">
              <div className="flex-shrink-0">
                <XCircleIcon className="h-5 w-5 text-red-400" aria-hidden="true" />
              </div>
              <div className="ml-3">
                <p className="text-sm font-medium text-red-800">{this.state.errorMessage}</p>
              </div>
            </div>
          </div>
        )}

        {/* Customer */}
        <label className="block mt-5">
          <span className="text-gray-700">Customer</span>
          <Select
            value={this.state.formCustomerOption}
            onChange={selectedOption => {
              // If selected user changes, get the tasks for them
              if (selectedOption.value != this.state.formCustomerOption?.value) {
                this.fetchTasksForUser(selectedOption.value)
              }
              this.setState({ formCustomerOption: selectedOption })
            }}
            options={this.state.customerOptions}
            placeholder={this.state.isLoading ? 'Loading...' : 'Select Customer'}
            isDisabled={this.state.isLoading}
            styles={reactSelectTailwindStyles}
          />
        </label>

        {/* Task */}
        <label className="block mt-5">
          <span className="text-gray-700">Task</span>
          <Select
            value={this.state.formTaskOption}
            onChange={selectedOption => {
              this.setState({ formTaskOption: selectedOption })
            }}
            options={this.state.taskOptions}
            placeholder={this.state.isLoading ? 'Loading...' : (this.state.formCustomerOption ? 'Select Task' : 'Select Customer First')}
            isDisabled={this.state.isLoading || !this.state.formCustomerOption}
            styles={reactSelectTailwindStyles}
          />
        </label>


        {/* Time Required */}
        <label className="block mt-5">
          <span className="text-gray-700">Time Required</span>
          <div className="mt-1 w-full flex rounded-md shadow-sm">
            <span className="inline-flex items-center px-3 rounded-l-md border border-r-0 border-gray-300 bg-gray-50 text-gray-500 shadow-sm">
              Minutes
            </span>
            <input 
              type="number" 
              className="flex-1 block w-full rounded-none rounded-r-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50 disabled:opacity-50"
              placeholder="57" 
              value={this.state.formTimeRequired}
              onChange={e => this.setState({ formTimeRequired: e.target.value })}
              pattern="[0-9]"
              disabled={this.state.isLoading}
            />
          </div>
        </label>

        {/* Cost Per Minute */}
        <label className="block mt-5">
          <span className="text-gray-700">Cost Per Minute</span>
          <div className="mt-1 w-full flex rounded-md shadow-sm">
            <span className="inline-flex items-center px-3 rounded-l-md border border-r-0 border-gray-300 bg-gray-50 text-gray-500 shadow-sm">
              ¥
            </span>
            <input 
              type="number" 
              className="flex-1 block w-full rounded-none rounded-r-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50 disabled:opacity-50"
              placeholder="150" 
              value={this.state.formCostPerMinute}
              onChange={e => this.setState({ formCostPerMinute: e.target.value })}
              pattern="[0-9]"
              disabled={this.state.isLoading}
            />
          </div>
        </label>
        <label className="block mt-1">
          <span className="text-gray-500">Total Cost: {totalCost}</span>
        </label>

        {/* Message */}
        <label className="block mt-5">
          <span className="text-gray-700">Message</span>
          <textarea 
            className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50 disabled:opacity-50" 
            rows={4}
            disabled={this.state.isLoading}
            placeholder="Message with variables: {{task}}, {{time}}, {{cost}}"
            value={this.state.formMessage}
            onChange={e => this.setState({ formMessage: e.target.value })}
          />
        </label>
        <label className="block mt-1">
          <span className="text-gray-500">Variables: &#123;&#123;task&#125;&#125;, &#123;&#123;time&#125;&#125;, &#123;&#123;cost&#125;&#125;</span>
        </label>


        {/* Send Email Button */}
        <button 
          type="button" 
          className="inline-flex mt-5 items-center px-4 py-2 w-max border border-transparent shadow-sm text-base font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50"
          disabled={this.state.isLoading}
          onClick={this.sendAdditionalTimeEmail.bind(this)}
        >
          <MailIcon className="-ml-1 mr-3 h-5 w-5" />
          {this.state.isLoading ? 'Loading...' : 'Send Email'}
        </button>
      </div>
    )
  }

  renderPreview(totalCost: string) {
    let receipentUser = this.state.formCustomerOption ? _.find(this.fetchedUsers, ['id', this.state.formCustomerOption?.value]) : undefined
    let selectedTask = this.state.formTaskOption ? _.find(this.fetchedTasks, ['id', this.state.formTaskOption?.value]) : undefined

    let taskValue = selectedTask?.label || '...'
    let timeValue = prettyMilliseconds(parseInt(this.state.formTimeRequired || '57') * 60 * 1000, { verbose: true })
    let costValue = totalCost

    let renderedMessage = this.state.formMessage.replace(
      '{{task}}', `<span class="font-bold">${taskValue}</span>`
    ).replace(
      '{{time}}', `<span class="font-bold">${timeValue}</span>`
    ).replace(
      '{{cost}}', `<span class="font-bold">${costValue}</span>`
    )
    
    return (
      <div className="flex flex-1 flex-col h-full items-center bg-white border-gray-200 border-l-2 border-solid px-6 pt-3">
        <p className="text-2xl w-full mt-3">Additional Time Required For Task: {selectedTask?.label || '...'}</p>

        <div className="flex w-full items-center mt-8">
          <div className="flex flex-col flex-grow">
            <p className="text-sm font-medium">no-reply@mailmate.jp</p>
            <p className="text-sm text-gray-500">to: {receipentUser?.email || 'me'}</p>
          </div>

          <div className="flex">
            {/* Time format: Jul 26, 2021, 8:57 AM */}
            <p className="text-sm text-gray-500">{DateTime.local().toFormat('LLL d, y, h:mm a')}</p>
          </div>
        </div>

        <div className="flex flex-col mt-12" style={{width: 580}}>
          <img src={ImageMailLogo} width={200} height={33} />
        
          <p className="text-2xl mt-16 font-bold self-center">Additional Time Required</p>
          <p 
            className="mt-4" 
            dangerouslySetInnerHTML={{ __html: renderedMessage }}
          />

          <div
            style={{
              backgroundColor: 'rgb(202, 34, 40)',
              width: 210,
              height: 40,
              display: 'flex',
              color: 'white',
              alignItems: 'center',
              justifyContent: 'center',
              borderRadius: '5px',
              fontSize: '18px',
              alignSelf: 'center',
              marginTop: '40px'
            }}
          >
            Purchase Time
          </div>
          
          <div
            style={{
              backgroundColor: "rgb(243, 243, 243)",
              width: "100%",
              height: 54,
              display: 'flex',
              color: 'black',
              alignItems: 'center',
              justifyContent: 'center',
              borderRadius: '2px',
              marginTop: '45px'
            }}
          >
            Copyright © 2021 MailMate
          </div>
        </div>
      </div>
    )
  }

  // MARK: API 

  async fetchUsers() {
    try {
      let response = await client.query({ query: USERS })
      
      this.setState({
        customerOptions: response.data.users.map((user: IUser) => ({ value: user.id, label: user.profile?.displayName || user.email })),
        isLoading: false
      })

      this.fetchedUsers = response.data.users
    }
    catch(error) {
      this.setState({ errorMessage: messageForApolloErrorType(typeForApolloError(error)) })
    }
  }

  async fetchTasksForUser(userId: string) {
    this.setState({
      isLoading: true,
      taskOptions: [],
      formTaskOption: null
    })
    this.fetchedTasks = undefined

    try {
      let response = await client.query({ 
        query: ASSISTANT_TASKS,
        variables: {
          userId: userId,
          stateIn: ['pending', 'in_progress']
        }
      })

      this.setState({
        taskOptions: response.data.assistantTasks.map((task: IAssistantTask) => ({ value: task.id, label: task.label })),
        isLoading: false
      })

      this.fetchedTasks = response.data.assistantTasks
    }
    catch(error) {
      this.setState({ errorMessage: messageForApolloErrorType(typeForApolloError(error)) })
    }
  }

  async sendAdditionalTimeEmail() {
    // Ensure we have everything we need
    if (!this.state.formTaskOption?.value || _.isEmpty(this.state.formTimeRequired) || _.isEmpty(this.state.formCostPerMinute) || _.isEmpty(this.state.formMessage)) {
      this.setState({ errorMessage: 'Please complete all fields' })
      return
    }
    
    this.setState({
      isLoading: true, 
      errorMessage: undefined
    })

    try {
      let response = await client.mutate({
        mutation: SEND_ADDITIONAL_TIME_EMAIL_MUTATION,
        variables: { input: { 
          assistantTaskId: this.state.formTaskOption?.value,
          timeRequired: parseInt(this.state.formTimeRequired),
          costPerMinute: parseInt(this.state.formCostPerMinute),
          message: this.state.formMessage
        }}
      })

      // If error, throw and do standard error handling below 
      if (!response.data.sendAdditionalTimeEmail.success) {
        throw new APIMessageError(response.data.sendAdditionalTimeEmail.errorMessage)
      }

      this.setState({ showSuccessDialog: true })
    }
    catch(error) {
      let errorMessage = (error instanceof APIMessageError) ? error.message : messageForApolloErrorType(typeForApolloError(error))
      this.setState({ 
        isLoading: false,
        errorMessage: errorMessage
      })
    }
  }
}

// MARK: Styling & Components

const reactSelectTailwindStyles = {
  container: (provided, state) => ({
    ...provided,
    height: '42px',
    borderRadius: '0.375rem',
    boxShadow: '0 0 #0000, 0 0 #0000, 0 1px 2px 0 rgba(0, 0, 0, 0.05)',
    opacity: state.isDisabled ? 0.5 : 1,
  }),
  control: (provided) => ({
    ...provided,
    height: '100%',
    backgroundColor: 'white',
    borderColor: 'rgb(209, 213, 219)',
    borderRadius: '0.375rem',
    boxShadow: '0 0 #0000, 0 0 #0000, 0 1px 2px 0 rgba(0, 0, 0, 0.05)',
    '&:hover': {
      borderColor: 'rgb(209, 213, 219)',
    },
    '&:focus-within': {
      borderColor: '#A5B4FC',
      '--tw-ring-offset-shadow': 'var(--tw-ring-inset) 0 0 0 var(--tw-ring-offset-width) var(--tw-ring-offset-color)',
      '--tw-ring-shadow': 'var(--tw-ring-inset) 0 0 0 calc(3px + var(--tw-ring-offset-width)) var(--tw-ring-color)',
      '--tw-ring-color': 'rgba(199, 210, 254, var(--tw-ring-opacity))',
      '--tw-ring-opacity': 0.5,
      boxShadow: 'var(--tw-ring-offset-shadow), var(--tw-ring-shadow), var(--tw-shadow, 0 0 #0000)'
    }
  }),
  input: (provided) => ({
    ...provided,
    'input': {
      boxShadow: 'none !important'
    }
  }),
  placeholder: (provided) => ({
    ...provided,
    color: '#6B7280'
  }),
  option: (provided, state) => ({
    ...provided,
    backgroundColor: state.isSelected ? '#6366F1' : 'white',
    '&:hover': {
      backgroundColor: state.isSelected ? '#6366F1' : '#E0E7FF',
    }
  })
}


const SuccessDialog = (props: {isOpen: boolean}) => (
  <Dialog
    open={props.isOpen}
    onRequestClose={() => {}}
    hideCloseButton={true}
  >
    <div className="flex flex-col items-center">
      <CheckCircleIcon className="h-12 w-12 text-green-500" />
      <h3 className="text-xl">Email Sent</h3>

      <button 
        type="button" 
        className="inline-flex mt-5 items-center px-4 py-1 w-max border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50"
        onClick={() => window.location.href = '/boxm293/bebop/'}
      >
        Go To Home
      </button>
    </div>
  </Dialog>
)