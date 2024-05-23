# Reports! In Slack! Imagine that! 
namespace :slack_reporting do
  # Daily Report
  # Every day at 9am JST
  task daily: :environment do
    slack_message = "*Daily Report :pikachu_wave:*\n"
    slack_message += "*Monthly Revenue:* #{ActionController::Base.helpers.humanized_money_with_symbol(Reporting::Revenue.current_month)}\n"
    slack_message += "*Monthly Revenue (Assistant):* #{ActionController::Base.helpers.humanized_money_with_symbol(Reporting::RevenueAssistant.current_month)}\n"
    slack_message += "*Monthly Revenue (Mail):* #{ActionController::Base.helpers.humanized_money_with_symbol(Reporting::RevenueMail.current_month)}\n"
    slack_message += "*Monthly Revenue (Manually Charged):* #{ActionController::Base.helpers.humanized_money_with_symbol(Reporting::RevenueMisc.current_month)}\n"
    slack_message += "*Estimated MRR:* #{ActionController::Base.helpers.humanized_money_with_symbol(Reporting::EstimatedMrr.currently)}\n"
    slack_message += "*Stripe MRR:* #{ActionController::Base.helpers.humanized_money_with_symbol(Reporting::StripeMrr.call)}\n"
    slack_message += "*Assistant Time Used* #{ActionController::Base.helpers.distance_of_time(Reporting::TimeUsed.current_month * 60, accumulate_on: :hours)}\n"
    slack_message += "*Assistant Time Allocated* #{ActionController::Base.helpers.distance_of_time(Reporting::TimeAllocated.current_month * 60, accumulate_on: :hours)}"
    slack_message += " #{(Rails.env.development? ? '_(Development)_' : '')}"

    SlackNotificationJob.perform_later(slack_message)
    puts "Done!"
  end

  # Weekly Report
  # Every Monday at 9am JST for the previous week
  task weekly: :environment do
    time_now_jst = Time.now.in_time_zone('Asia/Tokyo')

    # Exit early/ignore if not start of week (Monday)
    next if time_now_jst.wday != 1

    # We're working off last week
    last_week_start = (time_now_jst - 1.week).beginning_of_week
    last_week_end = last_week_start.end_of_week
    time_format = '%H:%M %a %-d %b %Z' # "00:00 Mon 21 Jun JST"

    # Get our metrics
    stripe_mrr = Reporting::StripeMrr.call
    stripe_ad_hoc = Reporting::StripeAdHoc.call(last_week_start..last_week_end)
    
    # Compose our slack message
    slack_message = "*Weekly Report :asdf:*\n"
    slack_message += "- Stripe MRR: #{ActionController::Base.helpers.humanized_money_with_symbol(stripe_mrr)}\n"
    slack_message += "- Stripe Ad Hoc: #{ActionController::Base.helpers.humanized_money_with_symbol(stripe_ad_hoc)} for #{last_week_start.strftime(time_format)} to #{last_week_end.strftime(time_format)}\n"
    slack_message += "- #{(Rails.env.development? ? '_(Development)_' : '')}"

    # Send it! 
    SlackNotificationJob.perform_later(slack_message)
    puts "Done!"
  end

  # Monthly Report
  # Every 1st of month, so monthly report for June, would come out 1st of July
  task monthly: :environment do
    time_now_jst = Time.now.in_time_zone('Asia/Tokyo')

    # Exit early/ignore if not 1st of month
    next if time_now_jst.day != 1

    # We're working off last week
    last_month_start = (time_now_jst - 1.month).beginning_of_month
    last_month_end = last_month_start.end_of_month
    time_format = '%H:%M %a %-d %b %Z' # "00:00 Mon 21 Jun JST"

    # Get our metrics
    stripe_mrr = Reporting::StripeMrr.call
    stripe_ad_hoc = Reporting::StripeAdHoc.call(last_month_start..last_month_end)
    
    # Compose our slack message
    slack_message = "*Monthly Report :homerintobushes:*\n"
    slack_message += "- Stripe MRR: #{ActionController::Base.helpers.humanized_money_with_symbol(stripe_mrr)}\n"
    slack_message += "- Stripe Ad Hoc: #{ActionController::Base.helpers.humanized_money_with_symbol(stripe_ad_hoc)} for #{last_month_start.strftime(time_format)} to #{last_month_end.strftime(time_format)}\n"
    slack_message += "- #{(Rails.env.development? ? '_(Development)_' : '')}"

    # Send it! 
    SlackNotificationJob.perform_later(slack_message)
    puts "Done!"
  end
end