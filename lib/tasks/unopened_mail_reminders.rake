namespace :unopened_mail_reminders do
  task three_days: :environment do
    users_counter = 0
    users = User.where(current_sign_in_at: 3.days.ago.beginning_of_day..2.days.ago.beginning_of_day)
    users = users.select { |user| user.postal_mails.unopened.count > 0 }
    users_count = users.count

    users.each do |user|
      reminder = user.reminders.create(kind: 'unopened_mail_three_days')
      reminder.send_email!

      users_counter += 1
      puts "#{users_counter}/#{users_count}"
    end

    puts "Done!"
  end

  task ten_days: :environment do
    users_counter = 0
    users = User.where(current_sign_in_at: 10.days.ago.beginning_of_day..9.days.ago.beginning_of_day)
    users = users.select { |user| user.postal_mails.unopened.count > 0 }
    users_count = users.count

    users.each do |user|
      reminder = user.reminders.create(kind: 'unopened_mail_ten_days')
      reminder.send_email!

      users_counter += 1
      puts "#{users_counter}/#{users_count}"
    end

    puts "Done!"
  end
end
