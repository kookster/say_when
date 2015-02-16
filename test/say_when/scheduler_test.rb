require 'minitest_helper'

describe SayWhen::Scheduler do

  before {
    SayWhen::logger = Logger.new('/dev/null')
  }

  describe 'class methods' do

    it 'can return singleton' do
      s = SayWhen::Scheduler.scheduler
      s.wont_be_nil
      s.must_equal SayWhen::Scheduler.scheduler
    end

    it 'can be configured' do
      SayWhen::Scheduler.configure do |scheduler|
        scheduler.storage_strategy = :memory
        scheduler.processor_class  = SayWhen::Test::TestProcessor
      end
      SayWhen::Scheduler.scheduler.storage_strategy.must_equal :memory
      SayWhen::Scheduler.scheduler.processor_class.must_equal SayWhen::Test::TestProcessor
    end

    it 'can schedule a new job' do
      SayWhen::Scheduler.configure do |scheduler|
        scheduler.storage_strategy = :memory
        scheduler.processor_class  = SayWhen::Test::TestProcessor
      end

      job = SayWhen::Scheduler.schedule(
        trigger_strategy: 'once',
        trigger_options: { at: 10.second.since },
        job_class: 'SayWhen::Test::TestTask',
        job_method: 'execute'
      )
      job.wont_be_nil
    end

  end

  describe 'instance methods' do

    before(:all) do
      SayWhen::Scheduler.configure do |scheduler|
        scheduler.storage_strategy = :memory
        scheduler.processor_class  = SayWhen::Test::TestProcessor
      end
    end

    let (:scheduler) { SayWhen::Scheduler.scheduler }

    it 'should instantiate the processor from its class' do
      scheduler.processor.must_be_instance_of(SayWhen::Test::TestProcessor)
    end

    it 'should get the job class based on the strategy' do
      scheduler.job_class.must_equal SayWhen::Storage::Memory::Job
    end

    it 'should start the scheduler running, and can stop it' do
      scheduler.wont_be :running

      scheduler_thread = Thread.start{ scheduler.start }
      sleep(0.2)
      scheduler.must_be :running

      scheduler.stop
      scheduler.wont_be :running
    end
  end
end
