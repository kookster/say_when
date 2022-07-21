require_relative '../spec_helper'
require_relative '../active_record_spec_helper'

describe SayWhen::Scheduler do

  describe "class methods" do

    it "can return singleton" do
      s = SayWhen::Scheduler.scheduler
      s.should_not be_nil
      s.should == SayWhen::Scheduler.scheduler
    end

    it "can be configured" do
      SayWhen::Scheduler.configure do |scheduler|
        scheduler.storage_strategy = :active_record
        scheduler.processor_class  = SayWhen::Test::TestProcessor
      end
      SayWhen::Scheduler.scheduler.storage_strategy.should == :active_record
      SayWhen::Scheduler.scheduler.processor_class.should == SayWhen::Test::TestProcessor
    end

    it "can schedule a new job" do
      SayWhen::Scheduler.configure do |scheduler|
        scheduler.storage_strategy = :active_record
        scheduler.processor_class  = SayWhen::Test::TestProcessor
      end
      SayWhen::Storage::ActiveRecord::Job.delete_all

      job = SayWhen::Scheduler.schedule(
        :trigger_strategy => 'once',
        :trigger_options  => {:at => 10.second.since},
        :job_class        => 'SayWhen::Test::TestTask',
        :job_method       => 'execute'
      )
      job.should_not be_nil
    end

    it "can process jobs when there are no jobs" do
      SayWhen::Storage::ActiveRecord::Job.delete_all

      SayWhen::Scheduler.configure do |scheduler|
        scheduler.storage_strategy = :active_record
        scheduler.processor_class  = SayWhen::Test::TestProcessor
      end
      job = SayWhen::Scheduler.scheduler.process_jobs
      job.should be_nil
    end

    it "can process jobs when there is a job" do
      SayWhen::Storage::ActiveRecord::Job.delete_all

      SayWhen::Scheduler.configure do |scheduler|
        scheduler.storage_strategy = :active_record
        scheduler.processor_class  = SayWhen::Test::TestProcessor
      end

      job = SayWhen::Scheduler.schedule(
        :trigger_strategy => 'once',
        :trigger_options  => {:at => 1.second.since},
        :job_class        => 'SayWhen::Test::TestTask',
        :job_method       => 'execute'
      )
      sleep(1)

      processed_job = SayWhen::Scheduler.scheduler.process_jobs
      processed_job.should_not be_nil
      processed_job.should == job
    end

    it "can process multiple waiting jobs" do
      SayWhen::Scheduler.configure do |scheduler|
        scheduler.storage_strategy = :active_record
        scheduler.processor_class  = SayWhen::Test::TestProcessor
      end
      SayWhen::Storage::ActiveRecord::Job.delete_all

      opts = {
        :trigger_strategy => 'once',
        :trigger_options  => {:at => 1.seconds.since},
        :job_class        => 'SayWhen::Test::TestTask',
        :job_method       => 'execute'
      }

      10.times{ SayWhen::Scheduler.schedule(opts) }
      sleep(1)

      job_count = SayWhen::Scheduler.scheduler.process_waiting_jobs(100)
      job_count.should == 10
    end
  end

  describe "instance methods" do

    before(:all) do
      SayWhen::Scheduler.configure do |scheduler|
        scheduler.storage_strategy = :active_record
        scheduler.processor_class  = SayWhen::Test::TestProcessor
      end
      @scheduler = SayWhen::Scheduler.scheduler
    end

    it "should instantiate the processor from its class" do      
      @scheduler.processor.should be_a(SayWhen::Test::TestProcessor)
    end

    it "should get the job class based on the strategy" do
      @scheduler.job_class.should == SayWhen::Storage::ActiveRecord::Job
    end

    it "should start the scheduler running and stop it" do
      @scheduler.running.should be_false

      # puts 'starting'
      scheduler_thread = Thread.start{@scheduler.start}
      # puts 'started'
      sleep(0.1)
      @scheduler.running.should == true

      # puts 'stop'
      @scheduler.stop
      # puts 'wait for it'
      @scheduler.running.should == false
    end
  end
end