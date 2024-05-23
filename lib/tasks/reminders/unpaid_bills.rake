namespace :reminders do
  namespace :unpaid_bills do
    task yesterday: :environment do
      bills_counter = 0
      bills = Bill.pending.where(due_date: Date.yesterday)
      bills_count = bills.count

      bills.each do |bill|
        reminder = bill.reminders.create(kind: 'unpaid_bill_yesterday')
        reminder.send_email!

        bills_counter += 1
        puts "#{bills_counter}/#{bills_count}"
      end

      puts "Done!"
    end

    task tomorrow: :environment do
      bills_counter = 0
      bills = Bill.pending.where(due_date: Date.tomorrow)
      bills_count = bills.count

      bills.each do |bill|
        reminder = bill.reminders.create(kind: 'unpaid_bill_tomorrow')
        reminder.send_email!

        bills_counter += 1
        puts "#{bills_counter}/#{bills_count}"
      end

      puts "Done!"
    end

    task three_days: :environment do
      bills_counter = 0
      bills = Bill.pending.where(due_date: 3.days.from_now)
      bills_count = bills.count

      bills.each do |bill|
        reminder = bill.reminders.create(kind: 'unpaid_bill_three_days')
        reminder.send_email!

        bills_counter += 1
        puts "#{bills_counter}/#{bills_count}"
      end

      puts "Done!"
    end
  end
end
