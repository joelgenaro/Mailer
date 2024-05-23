# Preview all emails at http://localhost:3000/rails/mailers/internal_mailer
class InternalMailerPreview < ActionMailer::Preview
  def consultation_email
    InternalMailer.consultation_email(ConsultationRequest.last.id)
  end

  def please_pay_bill_email
    InternalMailer.please_pay_bill_email(Bill.last.id)
  end

  def please_open_mail_email
    InternalMailer.please_open_mail_email(Mail::PostalMail.last.id)
  end

  def please_shred_mail_email
    InternalMailer.please_shred_mail_email(Mail::PostalMail.last.id)
  end

  def task_created_by_user
    InternalMailer.task_created_by_user(Assistant::Task.last.id)
  end

  # preview with fake value
  def notify_invalid_task_creation_email
    InternalMailer.notify_invalid_task_creation_email("test@localhost.com","user@request.mailmate.jp","Testing task creation to invalid address")
  end
end
