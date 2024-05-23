import _ from 'lodash'
import { DateTime } from 'luxon'
import React from 'react' 
import { USERS_WITH_SUBSCRIPTIONS } from '../../bebop/graphql/queries'
import { ISubscription, IUser } from '../../bebop/graphql/types'
import { APIMessageError, client, messageForApolloErrorType, typeForApolloError } from "../../bebop/lib/apollo"

interface UserAssistantSubscriptionDetailsProps {
  initialUserId?: string,
  allPlans: any
}

interface UserAssistantSubscriptionDetailsState {
  isLoading: boolean,
  errorMessage?: string,
  user?: IUser
  subscription?: ISubscription
}

/**
 * Displays a user's assistant subscription details,
 * for use in on the Admin task pages: app/admin/tasks.rb
 */
export default class UserAssistantSubscriptionDetails extends React.Component<UserAssistantSubscriptionDetailsProps, UserAssistantSubscriptionDetailsState> {
  userIdToFind?: string

  readonly state: UserAssistantSubscriptionDetailsState = {
    isLoading: false
  }

  componentDidMount() {
    // If provided initial user id, eg showing 
    // on an edit view, then load user immediately.
    // Otherwise we'll wait until user id is selected...
    if (this.props.initialUserId) {
      this.userIdToFind = this.props.initialUserId
      this.fetchUserWithSubscription()
    }

    // Listen for the user id select2 to be selected, and then 
    // load user accordingly. Note, we have to user jQuery here,
    // due to how select2 is built and doesnt dispatch native events
    // - https://github.com/select2/select2/issues/1908
    // - https://select2.org/programmatic-control/events
    $('#assistant_task_user_id').on('select2:select', (e: any) => {
      this.userIdToFind = e.target.value
      this.fetchUserWithSubscription()
    })
    $('#assistant_task_user_id').on('select2:clear', () => {
      this.userIdToFind = undefined
      this.forceUpdate()
    })
  }

  render() {
    // Loading
    if (this.state.isLoading) {
      return (<p>Loading...</p>)
    }

    // No user id to find
    if (!this.userIdToFind) {
      return (<p>Select a user to show Assistant subscription information</p>)
    }

    // Error
    if (this.state.errorMessage) {
      return (<p><b>Error</b>: {this.state.errorMessage}</p>)
    }

    // Get plan for subscription
    const plan = this.props.allPlans[this.state.subscription.plan]

    // If no plan, means its a legacy plan
    if (!plan) {
      return (<p>Legacy assistant plan, not showing details.</p>)
    }

    // Show subscription details
    return (
      <div style={{display: 'flex'}}>
        {
          [
            {
              title: `Subscription Details For ${this.state.user.email}`,
              rows: [
                {
                  label: 'Status',
                  value: this.state.subscription.status
                },
                {
                  label: 'Period Started At',
                  value: DateTime.fromISO(this.state.subscription.billingPeriodStartedAt).toFormat('HH:mm, ccc d/M/yy')
                },
                {
                  label: 'Period Ends At',
                  value: DateTime.fromISO(this.state.subscription.billingPeriodEndsAt).toFormat('HH:mm, ccc d/M/yy')
                },
                {
                  label: 'Started At',
                  value: DateTime.fromISO(this.state.subscription.billingStartedAt).toFormat('HH:mm, ccc d/M/yy')
                }
              ]
            },
            {
              title: 'Plan Details',
              rows: [
                {
                  label: 'Plan Name',
                  value: plan.title,
                },
                {
                  label: 'Personal Tasks',
                  value: plan.configuration.personal_tasks ? '✅' : '🚫',
                },
                {
                  label: 'Business Tasks',
                  value: plan.configuration.business_tasks ? '✅' : '🚫',
                },
                {
                  label: 'Task Priorization Allowed',
                  value: plan.configuration.task_priorization_allowed ? '✅' : '🚫',
                }
              ]
            },
            {
              title: 'Plan Communication Channels',
              rows: [
                {
                  label: 'Dashboard',
                  value: plan.configuration.communication_dashboard ? '✅' : '🚫'
                },
                {
                  label: 'Email',
                  value: plan.configuration.communication_email ? '✅' : '🚫'
                },
                {
                  label: 'Chat Apps',
                  value: plan.configuration.communication_chat_apps ? '✅' : '🚫'
                },
                {
                  label: 'Phone',
                  value: plan.configuration.communication_phone ? '✅' : '🚫'
                }
              ]
            }
          ].map(item => (
            <div key={item.title} className="attributes_table" style={{ margin: '0px 20px', width: '100%' }}>
              <table cellSpacing="0" cellPadding="0">
                <thead>
                  <tr>
                    <th className="col" colSpan={2}>{item.title}</th>
                  </tr>
                </thead>
                <tbody>
                  {item.rows.map(row => (
                    <tr key={row.label} className="row">
                      <th style={{whiteSpace: 'nowrap'}}>{row.label}</th>
                      <td style={{whiteSpace: 'nowrap'}}>{row.value}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          ))
        }
      </div>
    )
  }

  // MARK: API 

  async fetchUserWithSubscription() {
    this.setState({ isLoading: true, user: undefined, subscription: undefined, errorMessage: undefined })

    try {
      let response = await client.query({ 
        query: USERS_WITH_SUBSCRIPTIONS,
        variables: {
          idEq: this.userIdToFind
        }
      })

      // Handle if no user found
      if (response.data.users.length === 0) {
        throw new APIMessageError(`User not found for id ${this.userIdToFind}`)
      }

      // Handle if no assistant subscription found
      let user: IUser = _.first(response.data.users)
      let subcription: ISubscription = _.find(user.subscriptions, ['planType', 'assistant'])
      if (!subcription) {
        throw new APIMessageError(`No assistant subscription found for user ${user.email}`)
      }
      
      // Set the things
      this.setState({ isLoading: false, user: user, subscription: subcription })
    }
    catch(error) {
      let errorMessage = (error instanceof APIMessageError) ? error.message : messageForApolloErrorType(typeForApolloError(error))
      this.setState({ isLoading: false, errorMessage: errorMessage })
    }
  }
}

