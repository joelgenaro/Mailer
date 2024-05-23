# Preview all emails at http://localhost:3000/rails/mailers/assistant/task_mailer
module Assistant
  class TaskMailerPreview < ActionMailer::Preview
    def created_email
      Assistant::TaskMailer.created_email(Assistant::Task.last.id)
    end

    def completed_email
      Assistant::TaskMailer.completed_email(Assistant::Task.complete.last.id)
    end

    def payment_email
      Assistant::TaskMailer.payment_email(Assistant::Task.last.id)
    end

    def buy_additional_time_email
      task = Assistant::Task.where(state: 'in_progress').last
      minutes = 15
      cost = 1000
      message = 'In order to complete your task {{task}}, you require an additional {{time}} for {{cost}}. Please purchase the additional time in order to complete your task and avoid delays.'

      created_at, digest = Assistant::BuyAdditionalTime.generate_link_digest(
        task: task,
        minutes: minutes,
        cost: cost
      )

      Assistant::TaskMailer.buy_additional_time_email(
        task.id,
        minutes, 
        cost, 
        created_at, 
        digest,
        message
      )
    end
  end
end
