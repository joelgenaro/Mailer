# Preview all emails at http://localhost:3000/rails/mailers/mail/postal_mail_mailer
module Mail
  class PostalMailMailerPreview < ActionMailer::Preview
    def opened_email
      Mail::PostalMailMailer.opened_email(Mail::PostalMail.last.id)
    end

    def updated_email
      Mail::PostalMailMailer.updated_email(Mail::PostalMail.last.id)
    end

    def created_email
      Mail::PostalMailMailer.created_email(Mail::PostalMail.last.id)
    end

    def forwarded_email
      Mail::PostalMailMailer.forwarded_email(Mail::ForwardRequest.last)
    end

    def shredded_email
      Mail::PostalMailMailer.shredded_email(Mail::PostalMail.last.id)
    end

    def email_forward_email
      Mail::PostalMailMailer.email_forward_email(Mail::EmailForward.last.postal_mail_id,Mail::EmailForward.last.email_address.split(','))
    end
  end
end
