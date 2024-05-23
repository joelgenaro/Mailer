import React, { useEffect, useState } from 'react'
import { useMutation } from '@apollo/client'
import { NewsletterSubscription } from '../../src/graphql/newsletterSubscription'
import { client } from '../../src/apollo'
import styled, { createGlobalStyle } from 'styled-components'
import ImageBackgroundMap from './assets/background-map.png'
import GenericModal from '../generic_modal'

/**
 * Common for allowing users sign up to the newsletter.
 * 
 * This can either be shown directly, or via modal (which we make pop up
 * after ~30 seconds on page)
 */
const BlogNewsletterSignUp: React.FC<{
  logoURL: string, // MailMate logo url, from our assets pipeline
  asModal: boolean, // If to show in a modal
  immediatelyShowModal?: boolean // If showing as modal, if to show immediately
}> = (props) => {
  /**
   * State
   */
  const [modalIsOpen, setModalIsOpen] = useState(false)
  const [mode, setMode] = useState<'normal'|'loading'|'completed'>('normal')
  const [errorMessage, setErrorMessage] = useState<string|undefined>()
  const [successMessage, setSuccessMessage] = useState<string|undefined>()
  const [formName, setFormName] = useState('')
  const [formEmail, setFormEmail] = useState('')

  /**
   * Effect to auto show modal after 30 seconds, if supposed to,
   * or immediately open if the prop is set
   */
  useEffect(()=>{
    // Do nothing if not showing as modal
    if (!props.asModal) return 

    // If to show immediately
    if (props.immediatelyShowModal) {
      setModalIsOpen(true)
    }
    // Otherwise show after how ever many seconds
    else {
      const waitTime = 30000 // 30 seconds
      setTimeout(() => setModalIsOpen(true), waitTime)
    }
  },[])

  /**
   * Mutation for signing up to newsletter
   */
  const [mutate] = useMutation(NewsletterSubscription.SubscribeRequest, {
    client: client,
    variables: {
      input: {
        name: formName,
        email: formEmail,
      }
    }
  })

  /**
   * Method to handle form submit
   */
  const onSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()

    // Reset state
    setErrorMessage(undefined)
    setSuccessMessage(undefined)

    // Ensure email 
    if (formEmail.trim() === '') {
      setErrorMessage('Email cannot be blank')
      return
    }

    // Make the request
    try {
      setMode('loading')
      const response = await mutate()

      // Success
      if (response.data.newsletterSubscription.success) {
        setSuccessMessage(response.data.newsletterSubscription.message)
        setMode('completed')
      }
      // Error 
      else {
        setErrorMessage(response.data.newsletterSubscription.message)
        setMode('normal')
      }
    }
    catch (e) {
      setErrorMessage('Something went wrong, please try again')
      setMode('normal')
    }
  }

  /**
   * The actual content, which we'll directly show, or wrap in a modal
   */
  const renderContent = () => (
    <Container>
      {/* Logo */}
      <LogoImage src={props.logoURL} />

      {/* Content (with map background) */}
      <Content>
        {/* Title */}
        <Title>The <TitleHighlight>quickest way</TitleHighlight> to sound clever about Japan. <TitleHighlight>Immediately helpful</TitleHighlight> and only twice a month.</Title>

        {/* Points */}
        <Points>
          <li>Obscure trivia</li>
          <li>Data depicted</li>
          <li>Survey summaries</li>
          <li>Key blog excerpts</li>
          <li>3-minute reads</li>
          <li>&lt; 0.2% unsubscribe</li>
        </Points>

        {/* Form */}
        <Form onSubmit={onSubmit}>
          {/* Messages */}
          {successMessage && 
            <Message isError={false}>{successMessage}</Message>
          }
          {errorMessage && 
            <Message isError={true}>
              {errorMessage}
            </Message>
          }
        
          {/* Inputs */}
          <Input type="text" value={formName} onChange={(e) => setFormName(e.target.value)} placeholder="First Name" disabled={mode != 'normal'} />

          <Input type="email" value={formEmail} onChange={(e) => setFormEmail(e.target.value)} placeholder="Email"  disabled={mode != 'normal'} />

          <Button disabled={mode != 'normal'}>
            { mode == 'normal' && 'Get Japan Insights' }
            { mode == 'loading' && 'Loading...' }
            { mode == 'completed' && 'Thank You!' }
          </Button>
        </Form>
      </Content>
    </Container>
  )

  /**
   * Render
   * If we're showing directly or in a modal
   */
  if (!props.asModal) {
    return renderContent()
  }
  else {
    return (
      <>
        {/* Modal itself */}
        <GenericModal
          shouldCloseOnEsc={false}
          isOpen={modalIsOpen}
          onRequestClose={() => {
            // Reset all the things
            setModalIsOpen(false)
            setMode('normal')
            setErrorMessage(undefined)
            setSuccessMessage(undefined)
            setFormName('')
            setFormEmail('')
          }}
          customClass="BlogNewsletterSignUp__modal"
          bodyCustomClass="BlogNewsletterSignUp__modal__body"
        >
          {/* Content */}
          {renderContent()}
        </GenericModal>

        {/* Styles for modal */}
        <GlobalModalStyle />
      </>
    )
  }
}
export default BlogNewsletterSignUp

const Container = styled.div`
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 100%;
  font-family: Montserrat;
  padding: 15px;
  text-align: left;
`

const Content = styled.div`
  display: flex;
  flex-direction: column;
  max-width: 600px;
  background-image: url(${ ImageBackgroundMap });
  background-position: center top;
  background-repeat: no-repeat;
  background-size: contain;
  padding: 20px;
`

const LogoImage = styled.img`
  height: 25px;
  width: 150px;
  align-self: center;
  margin-bottom: 15px;
`

const Title = styled.p`
  font-style: italic;
  font-weight: 700;
  font-size: 29px;
  line-height: 40px;
  color: #333333;

  @media (max-width: 700px) {
    font-size: 22px;
    line-height: 32px;
  }
`

const TitleHighlight = styled.span`
  font-weight: 900;
  color: #ff9900;
`

const Points = styled.ul`
  padding-left: 40px;

  @media (max-width: 700px) {
    padding-left: 20px;
  }

  li {
    font-style: italic;
    font-weight: 700;
    font-size: 18px;
    line-height: 40px;
    color: #333333;

    @media (max-width: 700px) {
      line-height: 30px;
    }
  }
`

const Form = styled.form`
  margin-left: 15px;
  margin-right: 15px;

  @media (max-width: 700px) {
    margin-left: 0px;
    margin-right: 0px;
  }
`

const Message = styled.div<{isError: boolean}>`
  background-color: ${props => props.isError ? '#fbf0df' : '#def0e5' };
  color: ${props => props.isError ? '#b43e29' : '#1e7b2a' };
  padding: 10px 15px;
  font-size: 16px;
  border-radius: 6px;
  margin-bottom: 15px;
`

const Input = styled.input`
  appearance: none;
  border: 1px solid #949494;
  border-radius: 9px;
  padding: 10px 15px;
  margin-bottom: 15px;
  font-size: 18px;
  width: 100%;
  color: #333333;

  &::placeholder {
    color: #949494;
  }

  &:focus {
    border-color: #eca713;
    outline: 0;
    box-shadow: 0 0 0 3px rgba(255, 176, 0, 0.5);
  }
`

const Button = styled.button`
  cursor: pointer;
  appearance: none;
  background: #FFB000;
  border: 4px solid #FFB000;
  border-radius: 50px;
  border-style: solid;
  outline: none;
  width: fit-content;
  padding: 5px 24px;

  color: #ffffff;
  font-style: normal;
  font-weight: 800;
  font-size: 22px;
  line-height: 40px;
  text-transform: uppercase;

  @media (max-width: 700px) {
    font-size: 16px;
  }

  &:hover {
    background: #e6a519;
    border-color: #e6a519;
  }

  &:focus {
    border-color: #e6a519;
    box-shadow: 0 0 0 3px rgba(255, 176, 0, 0.5);
  }

  &:disabled {
    cursor: default;
    background: #ffffff;
    color: #FFB000;
    border-color: #FFB000;
  }
`

const GlobalModalStyle = createGlobalStyle`
  .BlogNewsletterSignUp__modal {
    width: 100%;
    max-width: 650px;

    @media (max-width: 700px) {
      width: 100%;
    }
  }

  .BlogNewsletterSignUp__modal__body {
    padding: 0px;
  }
`