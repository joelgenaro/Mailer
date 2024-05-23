require 'rails_helper'

RSpec.describe Assistant::BuyAdditionalTime do
  before(:all) do 
    @task = create(:assistant_task, id: 1111111)
    @minutes = 15
    @cost = 1000
  end

  after(:all) do 
    @task.destroy
  end

  context 'generate_link_digest' do
    it 'generates a digest' do
      Timecop.freeze(Time.parse("2021-08-03T19:00:13+01:00")) do
        created_at, digest = Assistant::BuyAdditionalTime.generate_link_digest(
          task: @task,
          minutes: @minutes,
          cost: @cost
        )
        expect(created_at).to eq("2021-08-04T03:00:13+09:00")
        expect(digest).to eq("1ace71e342a8bf9ce1b706839105ba99837fa9a517d59a2b285d5bab5d6607bd")
      end
    end

    it 'raises an error if task if already completed' do 
      Timecop.freeze(Time.parse("2021-08-03T19:00:13+01:00")) do
        completed_task = create(:assistant_task, :completed)
        expect(completed_task.state).to eq('complete')

        expect {
          Assistant::BuyAdditionalTime.generate_link_digest(
            task: completed_task,
            minutes: @minutes,
            cost: @cost
          )
        }.to raise_error(Assistant::BuyAdditionalTime::Error, 'Task is already complete')
      end
    end
  end

  context 'validate_link_digest' do 
    it 'validates provided digest' do
      # Have time allocations before, to ensure they don't interfere
      created_at = Time.parse("2021-08-03T19:00:13+01:00")
      create(:assistant_time_allocation, user: @task.user, created_at: created_at)
      create(:assistant_time_allocation, user: @task.user, created_at: created_at - 1.minute)
      create(:assistant_time_allocation, user: @task.user, created_at: created_at - 10.minutes)
      create(:assistant_time_allocation, user: @task.user, created_at: created_at - 10.days)

      success, error_message = Assistant::BuyAdditionalTime.validate_link_digest(
        task: @task,
        minutes: @minutes,
        cost: @cost,
        created_at: "2021-08-04T03:00:13+09:00",
        digest: "1ace71e342a8bf9ce1b706839105ba99837fa9a517d59a2b285d5bab5d6607bd"
      )

      expect(success).to eq(true)
      expect(error_message).to be_nil
    end

    it 'errors if time allocation created after, thus invalidating it' do 
      created_at = Time.parse("2021-08-03T19:00:13+01:00")
      time_allocation_after = create(:assistant_time_allocation, user: @task.user, created_at: created_at + 1.minute)

      success, error_message = Assistant::BuyAdditionalTime.validate_link_digest(
        task: @task,
        minutes: @minutes,
        cost: @cost,
        created_at: "2021-08-04T03:00:13+09:00",
        digest: "1ace71e342a8bf9ce1b706839105ba99837fa9a517d59a2b285d5bab5d6607bd"
      )

      expect(success).to eq(false)
      expect(error_message).to eq("Link has expired")
    end
  
    it 'errors if invalid parameters provided' do 
      # Task - same user
      success, error_message = Assistant::BuyAdditionalTime.validate_link_digest(
        task: create(:assistant_task, user: @task.user),
        minutes: @minutes,
        cost: @cost,
        created_at: "2021-08-04T03:00:13+09:00",
        digest: "1ace71e342a8bf9ce1b706839105ba99837fa9a517d59a2b285d5bab5d6607bd"
      )
      expect(success).to eq(false)
      expect(error_message).to eq("Invalid link")
      
      # Task - different user
      success, error_message = Assistant::BuyAdditionalTime.validate_link_digest(
        task: create(:assistant_task),
        minutes: @minutes,
        cost: @cost,
        created_at: "2021-08-04T03:00:13+09:00",
        digest: "1ace71e342a8bf9ce1b706839105ba99837fa9a517d59a2b285d5bab5d6607bd"
      )
      expect(success).to eq(false)
      expect(error_message).to eq("Invalid link")

      # Task - already complete
      success, error_message = Assistant::BuyAdditionalTime.validate_link_digest(
        task: create(:assistant_task, :completed),
        minutes: 37,
        cost: @cost,
        created_at: "2021-08-04T03:00:13+09:00",
        digest: "1ace71e342a8bf9ce1b706839105ba99837fa9a517d59a2b285d5bab5d6607bd"
      )
      expect(success).to eq(false)
      expect(error_message).to eq("Invalid link, task already completed")

      # Minutes
      success, error_message = Assistant::BuyAdditionalTime.validate_link_digest(
        task: @task,
        minutes: 37,
        cost: @cost,
        created_at: "2021-08-04T03:00:13+09:00",
        digest: "1ace71e342a8bf9ce1b706839105ba99837fa9a517d59a2b285d5bab5d6607bd"
      )
      expect(success).to eq(false)
      expect(error_message).to eq("Invalid link")

      # Cost
      success, error_message = Assistant::BuyAdditionalTime.validate_link_digest(
        task: @task,
        minutes: @minutes,
        cost: 500,
        created_at: "2021-08-04T03:00:13+09:00",
        digest: "1ace71e342a8bf9ce1b706839105ba99837fa9a517d59a2b285d5bab5d6607bd"
      )
      expect(success).to eq(false)
      expect(error_message).to eq("Invalid link")

      # Created At 
      success, error_message = Assistant::BuyAdditionalTime.validate_link_digest(
        task: @task,
        minutes: @minutes,
        cost: @cost,
        created_at: "2021-08-05T05:00:13+09:00",
        digest: "1ace71e342a8bf9ce1b706839105ba99837fa9a517d59a2b285d5bab5d6607bd"
      )
      expect(success).to eq(false)
      expect(error_message).to eq("Invalid link")

      # Digest 
      success, error_message = Assistant::BuyAdditionalTime.validate_link_digest(
        task: @task,
        minutes: @minutes,
        cost: @cost,
        created_at: "2021-08-04T03:00:13+09:00",
        digest: "1BAD71e342a8bf9ce1b706839105ba99837fa9a517d59a2b285d5bab5d660BAD"
      )
      expect(success).to eq(false)
      expect(error_message).to eq("Invalid link")

      # Nils
      success, error_message = Assistant::BuyAdditionalTime.validate_link_digest(
        task: @task,
        minutes: nil,
        cost: nil,
        created_at: "2021-08-04T03:00:13+09:00",
        digest: "1ace71e342a8bf9ce1b706839105ba99837fa9a517d59a2b285d5bab5d6607bd"
      )
      expect(success).to eq(false)
      expect(error_message).to eq("Invalid link")
    end
  end

end