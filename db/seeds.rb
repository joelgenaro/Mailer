# Development
if Rails.env.development?
  puts "Seeding Development Data"

  # Admin User
  AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password', otp_required_for_login: false)

  # Assistant Only
  user_assistant_only = User.create!(
    email: 'assistant@only.com',
    password: 'password', 
    password_confirmation: 'password',
    stripe_customer_id: 'cus_Mgkc7i6GerPQWO',
    profile_attributes: {
      first_name: 'Assistant',
      last_name: 'Only',
      occupation: 'Developer',
      phone_number: '+353851231111'
    }
  )
  DemoSetup.perform(user_assistant_only) # From: app/lib/demo_setup.rb

  # Growth
  load "#{Rails.root}/db/seeds/growth.rb"

  # Below isn't working right now
  return

  ###
  # Assistant User
  # TODO Still: 
  # - Bill Payment Recieved
  # - Bill Paid 
  # - Bill Paid Automatically

  # User setup
  user_assistant_only = User.create!(
    email: 'assistant@only.com',
    password: 'password', 
    password_confirmation: 'password',
    stripe_customer_id: 'cus_Hr90va7NbpwvtH',
    profile_attributes: {
      first_name: 'Assistant',
      last_name: 'Only',
      occupation: 'Developer',
      phone_number: '+353851231111'
    }
  )
  stripe_session_assistant_only = OpenStruct.new(
    customer: Stripe::Customer.retrieve(user_assistant_only.stripe_customer_id),
    subscription: 'sub_Hr90jetoWydpu9',
    metadata: OpenStruct.new(
      subscription_name: 'personal',
      subscription_type: 'assistant'
    )
  )
  SetupAccount.new(
    user_assistant_only, 
    stripe_session_assistant_only
  ).do
  user_assistant_only.complete_profile!

  # Assistant Task - Pending
  assistant_task_pending = Assistant::Task.create!(
    label: 'Book A Restaurant With Buffalo Wings',
    notes: 'Buffalo sauce and blue cheese dip with celery is a must!',
    due_at: DateTime.now,
    task_list: user_assistant_only.task_list
  )

  # Assistant Task - In Progress
  assistant_task_in_progress = Assistant::Task.create!(
    label: 'Research Memes',
    notes: 'Particularly Dank Ones',
    due_at: DateTime.now,
    task_list: user_assistant_only.task_list
  )
  assistant_task_in_progress.in_progress!

  # Assistant Task - In Progress & Unpaid Bill
  assistant_task_in_progress_with_bill = Assistant::Task.create!(
    label: 'Book Me A Kite Surfing Lesson',
    notes: 'Ideally at 5pm on a Friday',
    due_at: DateTime.now,
    task_list: user_assistant_only.task_list
  )
  assistant_task_in_progress_with_bill.in_progress!
  Bill.create!(
    description: 'Kite Surfing Lesson Cost',
    user: user_assistant_only,
    billable: assistant_task_in_progress_with_bill,
    subtotal_amount: 5000,
    processing_fee_amount: 700,
    total_amount: 5700
  )

  # Assistant Task - Completed & 2 Time Entries
  assistant_task_completed = Assistant::Task.create!(
    label: 'Spend 30 Minutes Pontificating',
    notes: 'On life love and such',
    due_at: DateTime.now,
    task_list: user_assistant_only.task_list
  )
  assistant_task_completed.done!
  assistant_task_completed.time_entries << Assistant::TimeEntry.create(
    minutes: 15,
    started_at: DateTime.now
  )
  assistant_task_completed.time_entries << Assistant::TimeEntry.create(
    minutes: 15,
    started_at: (DateTime.now + 30.minutes),
  )
  
  # create reminders for reminder reminder mailer preview
  User.last.reminders.create(kind: 'unopened_mail_three_days')
  User.last.reminders.create(kind: 'unopened_mail_ten_days')
  Bill.pending.first.reminders.create(kind: 'unpaid_bill_yesterday')
  Bill.pending.first.reminders.create(kind: 'unpaid_bill_tomorrow')
  Bill.pending.first.reminders.create(kind: 'unpaid_bill_three_days')

  # create forward and email_forward requests for postal mailer preview
  Mail::ForwardRequest.create(postal_mail: Mail::PostalMail.last, address: "Kawabata Building, Hakata, Fukuoka")
  Mail::EmailForward.create(postal_mail: Mail::PostalMail.last, email_address: "another@example.com", forwarded_at:DateTime.now)
end