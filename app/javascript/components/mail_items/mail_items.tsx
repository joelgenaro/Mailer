// Dependencies
import * as React from 'react'
import DownloadButton from '../download_button'
import Lightbox from 'react-image-lightbox';
import 'react-image-lightbox/style.css'; // This only needs to be imported once in your app

// Props
interface MailItemsProps {
  items: Array<string>
  mailId: string
}

// State
interface MailItemsState {
  photoIndex: number,
  isOpen: boolean
}

/**
 * Mail Items
 */
export default class MailItems extends React.Component<MailItemsProps, MailItemsState> {
  /**
   * Initial State
   */
  readonly state = {
    photoIndex: 0,
    isOpen: false
  }

  /**
   * Renders the items
   */
  buildImages(items) {
    return items.map((image, index) => {
      const size = (index == 0) ? 'large' : 'thumbnail' // Make the first image larger

      return (
        <div className="mail-items__item" key={index} onClick={() => this.setState({ photoIndex: index, isOpen: true })}>
          <img src={image[size]} className="mail-items__item-img" />
        </div>
      )
    })
  }

  /**
   * Render
   */
  render() {
    const { items } = this.props
    const { photoIndex, isOpen } = this.state

    return (
      <div className="mail-items">
        {this.buildImages(items)}

        {isOpen && (
          <Lightbox
            mainSrc={items[photoIndex]['large']}
            nextSrc={items[(photoIndex + 1) % items.length]['large']}
            prevSrc={items[(photoIndex + items.length - 1) % items.length]['large']}
            onCloseRequest={() => this.setState({ isOpen: false })}
            onMovePrevRequest={() =>
              this.setState({
                photoIndex: (photoIndex + items.length - 1) % items.length,
              })
            }
            onMoveNextRequest={() =>
              this.setState({
                photoIndex: (photoIndex + 1) % items.length,
              })
            }
            toolbarButtons={[<DownloadButton fileUrl={items[photoIndex]['url']} mailId={this.props.mailId} />]}
          />
        )}
      </div>
    );
  }
}
