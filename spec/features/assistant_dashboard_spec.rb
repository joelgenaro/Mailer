require "rails_helper"
include BasicAuthHelper

RSpec.feature "Assistant dashboard", :type => :feature do
    before do 
        StripeMock.start
        @user = create(:user, :with_profile, :with_payment_method)
        @subscription = create(:subscription, :with_plan_assistant, user: @user)
        basic_auth_login()
        login_as(@user)
        visit tasks_path
    end

    scenario "visit empty dashboard" do
        expect(page).to have_text("You haven't added any tasks")
    end

    scenario "create a task" do
        fill_in 'assistant_task_label', with: "Test Task"
        fill_in 'assistant_task_notes', with: "Testing Task 1"
        find('#assistant_task_task_uploads_attributes_0_file').set('app/assets/images/frontend/sample-bills/water-bill.jpg')
        click_button("Create Task")
        expect(page).to have_text("Thanks! Your task has been added to the list.")
        expect(page).to have_text("Test Task")
    end 

    scenario "view a task" do
        @task = create(:assistant_task, task_list:@user.task_list, label: "Test Task", due_at: DateTime.now, notes: "Task description blah blah")
        visit tasks_path
        click_link("Test Task")
        expect(page).to have_text("Test Task")
        expect(page).to have_text("Notes:")
        expect(page).to have_text("Task description blah blah")
        expect(page).to have_text("Due date:")
        expect(page).to have_text Date.today.to_formatted_s(:long_ordinal)
        expect(page).to have_text("State:")
        expect(page).to have_text("Pending")
    end
    
    # scenario "edit a task" do
    #     @task = create(:assistant_task, task_list:@user.task_list, label: "Test Task", user:@user)
    #     visit tasks_path
    #     click_link("Test Task")
    #     click_link("✏️ Edit") # ActiveRecord::RecordNotFound
    #     fill_in 'assistant_task_label', with: "Test Task updated!"
    #     click_button("Update")
    #     expect(page).to have_text('Task has been updated')
    #     expect(page).to have_text("Test Task updated!")

    #     click_link("Test Task updated!")
    #     click_link("✏️ Edit")
    #     fill_in 'assistant_task_label', with: "Test Task update again"
    #     click_link("Back")
    #     expect(page).not_to have_text('Task has been updated')
    #     expect(page).not_to have_text("Test Task update again")
    # end

    scenario "delete a task" do
        @task = create(:assistant_task, task_list:@user.task_list, label: "Test Task", user:@user)
        visit tasks_path
        click_link("Test Task")
        click_link("❌ Delete")
        expect(page).to have_text('Task has been deleted')
        expect(page).not_to have_text("Test Task")
    end

    scenario "mark as complete" do
        @task = create(:assistant_task, task_list:@user.task_list, label: "Test Task", user:@user, state: "in_progress")
        visit tasks_path
        click_link("Test Task")
        click_button("✅ Mark as Complete")
        expect(page).to have_text('Task has been marked as complete!')
        expect(page).to have_link("Completed (1)")
    end

    scenario "Test filters" do
        @pending = create(:assistant_task, task_list:@user.task_list, label: "Pending Task", user:@user)
        @progress = create(:assistant_task, task_list:@user.task_list, label: "In progress Task", user:@user, state: "in_progress")
        @completed = create(:assistant_task, task_list:@user.task_list, label: "Completed Task", user:@user, state: "complete")
        visit tasks_path
        expect(page).to have_text("Pending Task")
        expect(page).to have_css(".tasks__task__details",count: 3)
        click_link("Pending (1)")
        expect(page).to have_css(".tasks__task__details",count: 1)
        click_link("In Progress (1)")
        expect(page).to have_css(".tasks__task__details",count: 1)
        click_link("Completed (1)")
        expect(page).to have_css(".tasks__task__details",count: 1)
    end

    scenario "search task list" do

        @task = create(:assistant_task, task_list:@user.task_list, label: "Some task label", user:@user)
        @test1 = create(:assistant_task, task_list:@user.task_list, label: "Test 1", user:@user)
        @test2 = create(:assistant_task, task_list:@user.task_list, label: "Test 2", user:@user)
        # search test mail
        fill_in 'search', with: 'Test'
        Capybara::RackTest::Form.new(page.driver, find('#search-form').native).submit({})
        expect(page).to have_text('Test 1')
        expect(page).to have_text('Test 2')
        expect(page).not_to have_text("Some task label")

        # search some notes with case insensitive
        fill_in 'search', with: 'sOme tasK'
        Capybara::RackTest::Form.new(page.driver, find('#search-form').native).submit({})
        expect(page).not_to have_text('Test ')
        expect(page).to have_text("Some task label")
    end

    scenario "task uploads" do
        # view uploaded image
        @task1 = create(:assistant_task, task_list:@user.task_list, label: "Task 1", user:@user, task_uploads_attributes: [{
            file: Rack::Test::UploadedFile.new("app/assets/images/frontend/sample-bills/water-bill.jpg")
        }])
        visit tasks_path
        click_link("Task 1")
        expect(page.find('.mail-items__item-img')['src']).to have_content @task1.task_uploads.first.file.filename.to_s

        # add another task upload
        @upload = Assistant::Task.find(@task1.id).task_uploads.new(file: Rack::Test::UploadedFile.new('app/assets/images/frontend/sample-bills/phone-bill.jpg'))
        @upload.save!
        visit tasks_path
        click_link("Task 1")
        expect(page.all('.mail-items__item-img').count).to eq(2)
    end
    
    scenario "Pay a bill" do
        @task = create(:assistant_task, task_list:@user.task_list, label: "Pay Bill Task", bill_attributes: {
            due_date: '2020-10-02 12:00:00',
            description: 'Water & Sewage bill from Tokyo Water',
            subtotal_amount: 5995,
            total_amount: 6475,
            processing_fee_amount: 480,
            user_id: @user.id
          })
        visit tasks_path
        click_link("Pay Bill Task")
        expect(page).to have_text("Outstanding Bill for this task ¥6,475")

        click_button("Pay Bill Now")
        expect(page).to have_text("Pay A Bill")
        expect(page).to have_text("¥6,475")
        expect(page).to have_text("Water & Sewage bill from Tokyo Water ¥5995 + ¥480 processing fee.")
        expect(page).to have_text("ending **** **** **** 4242")
        expect(page).to have_link("Change")
        expect(page).to have_button("Confirm Payment")
        click_button("Confirm Payment")

        expect(page).to have_text("Thanks! Your payment has been received!")
        expect(Bill.find(@task.bill.id).state).to eq('payment_received')
        # make sure modal is closed
        expect(page).not_to have_text("Pay A Bill")
        expect(page).not_to have_text("Outstanding Bill for this task ¥6,475")
    end
end