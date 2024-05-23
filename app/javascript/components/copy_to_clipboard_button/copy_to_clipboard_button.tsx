// Dependencies
import * as React from 'react'
import { CopyToClipboard } from 'react-copy-to-clipboard';

// Props
interface CopyToClipboardButtonProps {
  buttonClass: string,
  buttonLabel: string,
  text: string
}

// State
interface CopyToClipboardButtonState {
  //
}

/**
 * Mail Items
 */
export default class CopyToClipboardButton extends React.Component<CopyToClipboardButtonProps, CopyToClipboardButtonState> {
  /**
   * Initial State
   */
  readonly state = {
    //
  }

  /**
   * Render
   */
  render() {
    return (
      <CopyToClipboard text={this.props.text}>
        <button className={this.props.buttonClass} dangerouslySetInnerHTML={{__html: this.props.buttonLabel}} />
      </CopyToClipboard>
    );
  }
}
