# Preview all emails at http://localhost:3000/rails/mailers/reminder_mailer
class ReminderMailerPreview < ActionMailer::Preview
  def unpaid_bill_yesterday_email
    ReminderMailer.unpaid_bill_yesterday_email(Reminder.where(kind: 'unpaid_bill_yesterday').last.id)
  end

  def unpaid_bill_tomorrow_email
    ReminderMailer.unpaid_bill_tomorrow_email(Reminder.where(kind: 'unpaid_bill_tomorrow').last.id)
  end

  def unpaid_bill_three_days_email
    ReminderMailer.unpaid_bill_three_days_email(Reminder.where(kind: 'unpaid_bill_three_days').last.id)
  end

  def unopened_mail_three_days_email
    ReminderMailer.unopened_mail_three_days_email(Reminder.where(kind: 'unopened_mail_three_days').last.id)
  end

  def unopened_mail_ten_days_email
    ReminderMailer.unopened_mail_ten_days_email(Reminder.where(kind: 'unopened_mail_ten_days').last.id)
  end
end
