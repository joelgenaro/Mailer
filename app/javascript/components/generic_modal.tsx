import React from 'react'
import ReactModal from 'react-modal'

/**
 * A generic modal for generic purposes! 
 * Supports underlying ReactModal props too!
 */
const GenericModal: React.FC<
  {
    isOpen: boolean,
    onRequestClose?: () => void,
    children?: React.ReactNode,
    customClass?: string,
    buttonCustomClass?: string,
    bodyCustomClass?: string,
    showCloseButton?: boolean
  } & ReactModal.Props
> = ({isOpen, onRequestClose, children, customClass, buttonCustomClass, bodyCustomClass, showCloseButton, ...rest }) => {
  return (
    <ReactModal
      isOpen={isOpen}
      onRequestClose={onRequestClose}
      ariaHideApp={false}
      overlayClassName="generic-modal__overlay"
      className={`${customClass} generic-modal`}
      {...rest}
    >
      {showCloseButton && (
        <button className={`${buttonCustomClass} generic-modal__close`} onClick={onRequestClose} />
      )}
      <div className={`${bodyCustomClass} generic-modal__body`}>{children}</div>
    </ReactModal>
  )
}

GenericModal.defaultProps = {
  showCloseButton: true
}

export default GenericModal
