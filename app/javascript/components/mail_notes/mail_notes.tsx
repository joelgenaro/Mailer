// Dependencies
import * as React from 'react'
import { ApolloProvider, gql } from '@apollo/client'
import { client } from '../../src/apollo'
import { IUpdateNotesMutationInput } from '../../src/graphql/types'
import { t } from '../../src/locale';

// Props
interface MailNotesProps {
  id: string,
  text: string
}

// State
interface MailNotesState {
  text: string,
  isEditing: boolean,
  isSaving: boolean
}

const UPDATE_NOTES = gql`
  mutation updateNotes(
    $input: UpdateNotesMutationInput!
  ) {
    updateNotes(input: $input) {
      notes
    }
  }
`;

/**
 * Mail Notes
 */
export default class MailNotes extends React.Component<MailNotesProps, MailNotesState> {
  /**
   * Initial State
   */
  readonly state = {
    text: '',
    isEditing: false,
    isSaving: false
  }

  /**
   * Mount component
   */
  componentDidMount() {
    this.setState({ text: this.props.text })
  }

  /**
   * Returns the "Edit" button text
   */
  editButtonText() {
    return (this.state.text.length > 0) ? t('MailNotes.Edit Notes') : 'Add Notes'
  }

  /**
   * Submit class names
   */
  submitClassName() {
    let classNames = ['btn', 'btn-dark', 'btn-block', 'mail__submit']
    if (this.state.isSaving) {
      classNames.push('btn-disabled')
      classNames.push('mail__submit--loading')
    }
    return classNames.join(' ')
  }

  /**
   * Handles saving the notes
   */
  async handleSave(event) {
    event.preventDefault()

    this.setState({ isSaving: true })

    await client.mutate({ 
      mutation: UPDATE_NOTES,
      variables: { input: { id: this.props.id, notes: this.state.text } }
    }).then(({ data }) => {
      this.setState({ isSaving: false, isEditing: false })
    })
  }

  /**
   * Builds the "Edit" view
   * @return {[type]} [description]
   */
  buildEditView() {
    return (
      <>
        <textarea defaultValue={this.state.text} className="form-control mb-2" onChange={e => this.setState({ text: e.target.value })}></textarea>

        <button className={this.submitClassName()} disabled={this.state.isSaving} onClick={event => this.handleSave(event) }>
          <span className="mail__submit__text">Save Notes</span>
          <span className="mail__submit__spinner spinner-grow spinner-grow-sm" role="status" aria-hidden="true"></span>
        </button>
      </>
    )
  }

  /**
   * Builds the normal/text view
   */
  buildTextView() {
    return (
      <>
        { this.state.text.length > 0 &&
          <p>{this.state.text}</p>
        }
        <button className="btn btn-dark btn-block" onClick={event => this.setState({ isEditing: true })}>{this.editButtonText()}</button>
      </>
    )
  }

  /**
   * Render
   */
  render() {
    return (
      <>
        { this.state.isEditing && this.buildEditView() }
        { !this.state.isEditing && this.buildTextView() }
      </>
    );
  }
}
