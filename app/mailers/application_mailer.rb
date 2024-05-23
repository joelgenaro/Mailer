class ApplicationMailer < ActionMailer::Base
  layout 'mailers/layouts/mailer'

  private

  def internal_emails
    team_emails = ENV.fetch('ADMIN_EMAILS', ['admin@mailmate.jp']).split(',')
    team_emails.join(', ')
  end
end
