import React, { useState } from 'react'
import GenericModal from './generic_modal'
import axios from 'axios'

/**
 * Button used to show modal for requesting consultation on certain plans (ie Mail Corparate)
 */
const RequestConsultationModalButton: React.FC<{
  buttonClass: string,
  logoUrl: string,
  businessTypeOptions: [string, string][],
  formUrl: string,
  authenticityToken: string,
  planName: string,
}> = (props) => {
  const [open, setOpen] = useState(false)
  const [loading, setLoading] = useState(false)
  const [errorMessage, setErrorMessage] = useState<string|undefined>()
  const [showThanks, setShowThanks] = useState(false)
  const [formErrors, setFormErrors] = useState<any>({})
  const [formFirstName, setFormFirstName] = useState('')
  const [formLastName, setFormLastName] = useState('')
  const [formPhoneNumber, setFormPhoneNumber] = useState('')
  const [formEmail, setFormEmail] = useState('')
  const [formBusinessType, setFormBusinessType] = useState('')

  const onSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    setLoading(true)
    setFormErrors({})
    setErrorMessage(undefined)

    try {
      let response = await axios.post(
        props.formUrl, 
        {
          authenticity_token: props.authenticityToken,
          consultation_request: {
            first_name: formFirstName, 
            last_name: formLastName, 
            email: formEmail, 
            phone: formPhoneNumber, 
            business_type: formBusinessType,
            plan_name: props.planName,
            comment: "Via mail plans page"
          }
        },
        { headers: { 'Accept': 'application/json' } }
      )
      
      if (!response.data.success) {
        setFormErrors(response.data.errors)
      }
      else {
        setShowThanks(true)
      }
    }
    catch(e) {
      setErrorMessage("Something when wrong, please try again")
    }
    finally {
      setLoading(false)
    }
  }

  const isJP = (window.gon.locale === 'ja')
  const translations = {
    'Get Started': isJP ? 'お申し込みへ' : 'Get Started'
  }

  return (
    <>
      <button className={props.buttonClass} onClick={() => setOpen(true)}>{translations['Get Started']}</button>
      
      <GenericModal
        shouldCloseOnEsc={false}
        isOpen={open}
        onRequestClose={() => setOpen(false)}
      > 
        {/* Logo */}
        <img src={props.logoUrl} className="signup-modal__logo" />

        {/* Thanks */}
        {showThanks && 
          <>
            <h1 className="page__request-consultation-thanks__title">Thanks!</h1>
            <p className="page__request-consultation-thanks__subtitle">Thanks for requesting a consultation! A member of our team will contact you shortly.</p>
          </>
        }

        {/* Form */}
        {!showThanks &&
          <>
            {/* Message */}
            <div style={{textAlign: 'left'}}>
              <p>Tell us a little about yourself and we'll connect you with a MailMate expert who can share more about the product and answer any questions you have.</p>
            </div>

            {/* Error Message */}
            {errorMessage && 
              <div className="alert alert-danger">
                {errorMessage}
              </div>
            }

            {/* Form */}
            <div style={{textAlign: 'left'}}>
              <form onSubmit={onSubmit}>
                {/* First Name */}
                <div className={`form-group ${formErrors['first_name'] ? 'has-error' : ''}`}>
                  <label className="form-label">First Name</label>
                  <input type="text" className="form-control" onChange={(e) => setFormFirstName(e.target.value )} />
                  {formErrors['first_name'] && <div className="form_errors">{formErrors['first_name']}</div>}
                </div>

                {/* Last Name */}
                <div className={`form-group ${formErrors['last_name'] ? 'has-error' : ''}`}>
                  <label className="form-label">Last Name</label>
                  <input type="text" className="form-control" onChange={(e) => setFormLastName(e.target.value )} />
                  {formErrors['last_name'] && <div className="form_errors">{formErrors['last_name']}</div>}
                </div>

                {/* Phone */}
                <div className={`form-group ${formErrors['phone'] ? 'has-error' : ''}`}>
                  <label className="form-label">Phone</label>
                  <input type="text" className="form-control" onChange={(e) => setFormPhoneNumber(e.target.value )} />
                  {formErrors['phone'] && <div className="form_errors">{formErrors['phone']}</div>}
                </div>

                {/* Email */}
                <div className={`form-group ${formErrors['email'] ? 'has-error' : ''}`}>
                  <label className="form-label">Email</label>
                  <input type="email" className="form-control" onChange={(e) => setFormEmail(e.target.value )} />
                  {formErrors['email'] && <div className="form_errors">{formErrors['email']}</div>}
                </div>

                {/* Business Type */}
                <div className={`form-group ${formErrors['business_type'] ? 'has-error' : ''}`}>
                  <label className="form-label">Business Type</label>
                  <select className="form-control" value={formBusinessType} onChange={e => setFormBusinessType(e.target.value)}>
                    <option value="">Select one...</option>
                    { props.businessTypeOptions.map(x => <option key={x[0]} value={x[1]}>{x[0]}</option>) }
                  </select>
                  {formErrors['business_type'] && <div className="form_errors">{formErrors['business_type']}</div>}
                </div>

                {/* Submit */}
                <div className="form-group">
                  <button type="submit" className={`btn btn-primary btn-block signup-modal__submit ${loading ? 'btn-disabled' : ''}`} disabled={loading}>
                    <span className="signup-modal__submit__text">Request Consultation</span>
                    <span className="signup-modal__submit__spinner spinner-grow spinner-grow-sm" role="status" aria-hidden="true"></span>
                  </button>
                </div>
              </form>
            </div>
          </>
        }

      </GenericModal>
    </>
  )
}

export default RequestConsultationModalButton