// Dependencies
import * as React from 'react'

// Props
interface DownloadButtonProps {
  fileUrl: string
  mailId: string
}

// State
interface DownloadButtonState {
  //
}

/**
 * Mail Items
 */
export default class DownloadButton extends React.Component<DownloadButtonProps, DownloadButtonState> {
  /**
   * Initial State
   */
  readonly state = {
    //
  }

  /**
   * Returns the file name with extension
   */
  fileName() {
    return this.props.fileUrl.split('/').pop().split('#')[0].split('?')[0];
  }

  /**
   * Render
   */
  render() {
    return (
        <div>
          <a href={`/app/mails/${this.props.mailId}/generate_pdf`} target={"_blank"}>Download All</a>
          <a href={this.props.fileUrl} download={this.fileName()} className="download-button">
            Download
          </a>
        </div>
    );
  }
}
