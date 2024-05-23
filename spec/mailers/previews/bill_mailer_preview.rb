# Preview all emails at http://localhost:3000/rails/mailers/bill_mailer
class BillMailerPreview < ActionMailer::Preview
  def paid_email
    BillMailer.paid_email(Bill.where.not(paid_at: nil).last.id)
  end
end
