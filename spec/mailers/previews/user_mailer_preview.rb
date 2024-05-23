# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def onboard_email
    UserMailer.onboard_email(User.onboarded.last.id)
  end

  # notify_task_creation_fail_email preview with fake content
  def notify_task_creation_fail_email
    UserMailer.notify_task_creation_fail_email(User.last,User.last.email,'2022-05-25T14:50:10+09:00',"Subject must not be empty for task requests.")
  end
end
