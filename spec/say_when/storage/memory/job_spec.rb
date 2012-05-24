require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/../../../../lib/say_when/storage/memory/job'

describe SayWhen::Store::Memory::Job do

  before(:each) do
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

end
