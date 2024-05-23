desc 'Recalculate tasks list balances, notably to handle any newly expired time allocations'
task calculate_task_list_balances: :environment do
  # Get all task lists
  task_lists = Assistant::TaskList.all
  task_lists_count = task_lists.count

  puts "[calculate_task_list_balances] recalculating #{task_lists_count} Assistant::TaskList balances"

  # Do it 
  task_lists.each_with_index do |task_list, index|
    puts "[calculate_task_list_balances] #{index+1}/#{task_lists_count}: id #{task_list.id}"
    task_list.calculate_balance_seconds!
  end

  puts "[calculate_task_list_balances] Done!"
end