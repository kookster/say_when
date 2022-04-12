require_relative '../../../spec_helper'
require_relative '../../../../lib/say_when/storage/memory/job'

describe SayWhen::Store::Memory::Job do

  before(:each) do
    SayWhen::Store::Memory::Job._reset
    @valid_attributes = {
      :name       => 'Memory::Job::Test',
      :group      => 'Test',
      :data       => {:foo=>'bar', :result=>1},
      :job_class  => 'SayWhen::Test::TestTask',
      :job_method => 'execute'
    }
  end

  it "can be instantiated" do
    j = SayWhen::Store::Memory::Job.new(@valid_attributes)
    j.should_not be_nil
  end

  it "can execute the task for the job" do
    j = SayWhen::Store::Memory::Job.new(@valid_attributes)
    j.execute_job({:result=>1}).should == 1
  end

  it "can execute the job" do
    j = SayWhen::Store::Memory::Job.new(@valid_attributes)
    j.execute.should == 1
  end

  it "can reset acquired jobs" do
    j = SayWhen::Store::Memory::Job.new(@valid_attributes)
    j.status = 'acquired'
    j.updated_at = 2.hours.ago
    SayWhen::Store::Memory::Job.reset_acquired(3600)
    j.status.should == 'waiting'
  end

  it "can find the next job" do
    j = SayWhen::Store::Memory::Job.new(@valid_attributes)
    next_job = SayWhen::Store::Memory::Job.acquire_next(1.day.since)
    next_job.should == j
  end
end
