import React, { useRef } from 'react'
import { Fragment } from 'react'
import { Dialog as HeadlessUIDialog, Transition } from '@headlessui/react'
import { XIcon } from '@heroicons/react/outline'

// https://tailwindui.com/components/application-ui/overlays/modals
// https://headlessui.dev/react/dialog
const Dialog: React.FC<{ 
  open: boolean,
  onRequestClose: () => void,
  hideCloseButton?: boolean
}> = (props) => {
  return (
    <Transition.Root show={props.open} as={Fragment}>
      <HeadlessUIDialog as="div" auto-reopen="true" className="fixed z-10 inset-0 overflow-y-auto" onClose={props.onRequestClose}>
        <div className="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
          
          {/* Overlay */}
          <Transition.Child
            as={Fragment}
            enter="ease-out duration-300"
            enterFrom="opacity-0"
            enterTo="opacity-100"
            leave="ease-in duration-200"
            leaveFrom="opacity-100"
            leaveTo="opacity-0"
          >
            <HeadlessUIDialog.Overlay className="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity" />
          </Transition.Child>

          {/* Trick to vertically center dialog */}
          <span className="hidden sm:inline-block sm:align-middle sm:h-screen" aria-hidden="true">
            &#8203;
          </span>

          {/* Content */}
          <Transition.Child
            as={Fragment}
            enter="ease-out duration-300"
            enterFrom="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
            enterTo="opacity-100 translate-y-0 sm:scale-100"
            leave="ease-in duration-200"
            leaveFrom="opacity-100 translate-y-0 sm:scale-100"
            leaveTo="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
          >
            <div className="inline-block align-bottom bg-white rounded-lg px-4 pt-5 pb-4 text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full sm:p-6">
              {/* Close Button */}
              {!props.hideCloseButton && (
                <div className="hidden sm:block absolute top-0 right-0 pt-4 pr-4">
                  <button
                    type="button"
                    //  focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500
                    className="bg-white rounded-md text-gray-400 hover:text-gray-500"
                    onClick={() => props.onRequestClose()}
                  >
                    <XIcon className="h-6 w-6" aria-hidden="true" />
                  </button>
                </div>
              )}
              
              {/* Body */}
              {props.children}
            </div>
          </Transition.Child>
        </div>
      </HeadlessUIDialog>
    </Transition.Root>
  )
}

export default Dialog