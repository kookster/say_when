require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../active_record_spec_helper'

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

      job = SayWhen::Scheduler.schedule(
        :trigger_strategy => :once,
        :trigger_options  => 1.day.since,
        :job_class        => 'SayWhen::Test::TestTask',
        :job_method       => 'execute'
      )
      job.should_not be_nil
    end

  end

end