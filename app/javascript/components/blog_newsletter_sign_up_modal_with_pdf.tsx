import React, {useEffect, useState} from 'react'
import GenericModal from './generic_modal'
import { useMutation } from '@apollo/client'
import {NewsletterSubscription} from '../src/graphql/newsletterSubscription';
import { client } from '../src/apollo';

declare global { interface Window { _openBlogNewsletterSignUpModalWithPDF:any } }

/**
 * This is a newsletter sign up modal, similar to BlogNewsletterSignUp,
 * but for offering and sending the user a guide/pdf when they sign up.
 * 
 * Also known as a "magnet".
 * 
 * Future:
 * - Make it nicer like app/javascript/components/blog_newsletter_sign_up/blog_newsletter_sign_up.tsx 
 * - - Comments, Styled Components, Quality
 * - Kill app/assets/stylesheets/marketing/components/_blog-newsletter-sign-up-modal-with-pdf.scss
 */
const BlogNewsletterSignUpModalWithPDF: React.FC<{
    buttonClass: string,
    logoUrl: string,
}> = (props) => {
  const [open, setOpen] = useState(false);
  const [loading, setLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string|undefined>()
  const [successMessage, setSuccessMessage] = useState<string|undefined>()
  const [formErrors, setFormErrors] = useState<any>({})
  const [formName, setFormName] = useState('')
  const [formEmail, setFormEmail] = useState('')
  const [pdfType, setPdfType] = useState('')
  const [imageSrc, setImageSrc] = useState('')
  const [title, setTitle] = useState('')
  const [detail, setDetail] = useState('')

  useEffect(()=>{
    window._openBlogNewsletterSignUpModalWithPDF = (pdfType, title, detail, imageSrc) => {
      setOpen(true)
      setPdfType(pdfType)
      setTitle(decodeURI(title))
      setDetail(decodeURI(detail))
      setImageSrc(imageSrc)
    }
  },[])

  const [mutate] = useMutation(NewsletterSubscription.SubscribeRequest, {
    client: client,
    variables: {
      input: {
        name: formName,
        email: formEmail,
        pdfType: pdfType,
      }
    }
  });

  const closeSubscribeModal = () => {
    setOpen(false);
    setErrorMessage('');
    setSuccessMessage('');
    setFormErrors({});
    setFormName('');
    setFormEmail('');
    setPdfType('');
    setLoading(false);
  }

  const onSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    if(formEmail !== '') {
      setLoading(true);
      setFormErrors({});
      setErrorMessage('');
      setSuccessMessage('');

      await mutate().then((resp)=>{
        if(resp.data.newsletterSubscription.status == 200){
          setSuccessMessage(resp.data.newsletterSubscription.message);
          setLoading(false);

          setFormEmail('');
          setFormName('')
        }
        else {
          setErrorMessage(resp.data.newsletterSubscription.message);
          setLoading(false);
        }
      });
    } else {
      setFormErrors({
        email: 'Email field cannot be blank.'
      });
    }
  }

  return (
    <GenericModal
      shouldCloseOnEsc={false}
      isOpen={open}
      onRequestClose={() => closeSubscribeModal()}
      customClass="blog-newsletter-sign-up-modal-with-pdf-modal"
      buttonCustomClass="blog-newsletter-sign-up-modal-with-pdf-button"
      bodyCustomClass="blog-newsletter-sign-up-modal-with-pdf-body"
    >
      {/* Header */}
      <div className="generic-modal__header">
        {/* Title */}
        <div className="generic-modal__heading">
          { title }
        </div>

        {/* Detail (if provided) */}
        { detail && detail.trim() != '' && 
          <div className="generic-modal__heading__detail">
            { detail }
          </div>
        }
      </div>

      {/* Divider */}
      <hr />

      {/* Body */}
      <div className="blog-newsletter-sign-up-modal-with-pdf-body-form-container">
        {/* Form (Left) */}
        <div className="blog-newsletter-sign-up-modal-with-pdf-body-form">
          {/* Errors */}
          {errorMessage && 
            <div className="form_errors" style={{color: '#ff0000'}} >{errorMessage}</div>
          }

          {/* Success */}
          {successMessage && 
            <div className="newsletter-subscription__success">
              {successMessage}
            </div>
          }
          <form onSubmit={onSubmit}>
            {/* Name */}
            <div className={`form-group form-group--align-left ${formErrors['name'] ? 'has-error' : ''}`}>
              <label className="form-label">Name</label>
              <input type="text" className="form-control" onChange={(e) => setFormName(e.target.value )} />
              {formErrors['name'] && <div className="form_errors">{formErrors['name']}</div>}
            </div>

            {/* Email */}
            <div className={`form-group form-group--align-left ${formErrors['email'] ? 'has-error' : ''}`}>
              <label className="form-label">Email *</label>
              <input type="email" className="form-control" onChange={(e) => setFormEmail(e.target.value )} />
              {formErrors['email'] && <div className="form_errors">{formErrors['email']}</div>}
            </div>

            {/* Submit */}
            <div className="form-group">
              <button type="submit" className={`btn btn-primary btn-block signup-modal__submit ${loading ? 'btn-disabled' : ''}`} disabled={loading}>
                <span className="signup-modal__submit__text">Download</span>
                <span className="signup-modal__submit__spinner spinner-grow spinner-grow-sm" role="status" aria-hidden="true"></span>
              </button>
            </div>
          </form>

          {/* Footer */}
          <div className="blog-newsletter-sign-up-modal-with-pdf-text">
            <span>Your email and information will be safely stored in our database. We do not share or sell this information to anyone. You can unsubscribe from our emails at any time.</span>
          </div>
        </div>
          
        {/* Display Image (Right) */}
        <div className="blog-newsletter-sign-up-modal-with-pdf-body-image">
          <img src={imageSrc} style={{width: "100%"}} />
        </div>
      </div>
    </GenericModal>
  )
};
export default BlogNewsletterSignUpModalWithPDF;
