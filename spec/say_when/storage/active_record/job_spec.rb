require_relative '../../../spec_helper'
require_relative '../../../active_record_spec_helper'
require_relative '../../../../lib/say_when/storage/active_record/job'

describe SayWhen::Storage::ActiveRecord::Job do

  before(:each) do
    SayWhen::Storage::ActiveRecord::Job.delete_all

    @valid_attributes = {
      :trigger_strategy => :cron,
      :trigger_options  => {:expression => '0 0 12 ? * * *', :time_zone  => 'Pacific Time (US & Canada)'},
      :data             => {:foo=>'bar', :result=>1},
      :job_class        => 'SayWhen::Test::TestTask',
      :job_method       => 'execute'
    }
  end

  it "can be instantiated" do
    j = SayWhen::Storage::ActiveRecord::Job.create!(@valid_attributes)
    j.should_not be_nil
  end

  it "can execute the task for the job" do
    j = SayWhen::Storage::ActiveRecord::Job.create(@valid_attributes)
    j.execute_job({:result=>1}).should == 1
  end

  it "can execute the job" do
    j = SayWhen::Storage::ActiveRecord::Job.create(@valid_attributes)
    j.execute.should == 1
  end

  it "derives a trigger from the attributes" do
    t = SayWhen::Storage::ActiveRecord::Job.create(@valid_attributes)
    t.trigger.should_not be_nil
    t.trigger.should be_a SayWhen::Triggers::CronStrategy
  end

  it "has a waiting state on create" do
    t = SayWhen::Storage::ActiveRecord::Job.create(@valid_attributes)
    t.status.should == SayWhen::BaseJob::STATE_WAITING
  end

  it "has a next fire at set on create" do
    opts = @valid_attributes[:trigger_options]
    ce = SayWhen::CronExpression.new(opts[:expression], opts[:time_zone])
    j = SayWhen::Storage::ActiveRecord::Job.create(@valid_attributes)
    j.status.should == SayWhen::BaseJob::STATE_WAITING
    j.next_fire_at.should == ce.next_fire_at
  end

  it "resets acquired jobs" do
    old = 2.hours.ago
    j = SayWhen::Storage::ActiveRecord::Job.create!(@valid_attributes.merge({
      :status => 'acquired', :updated_at => old, :created_at => old
    }))

    SayWhen::Storage::ActiveRecord::Job.reset_acquired(3600)

    j.reload
    j.status.should == 'waiting'
  end

  it "can find the next job" do
    j2_opts = {
      :trigger_strategy => :cron,
      :trigger_options  => {:expression => '0 0 10 ? * * *', :time_zone  => 'Pacific Time (US & Canada)'},
      :data             => {:foo=>'can find the next job - j2', :result=>2},
      :job_class        => 'SayWhen::Test::TestTask',
      :job_method       => 'execute'
    }

    j1 = SayWhen::Storage::ActiveRecord::Job.create(@valid_attributes)
    j2 = SayWhen::Storage::ActiveRecord::Job.create(j2_opts)
    next_job = SayWhen::Storage::ActiveRecord::Job.acquire_next(25.hours.since)
    next_job.should == j2
  end

  it "can be fired" do
    opts = @valid_attributes[:trigger_options]
    ce = SayWhen::CronExpression.new(opts[:expression], opts[:time_zone])
    j = SayWhen::Storage::ActiveRecord::Job.create(@valid_attributes)
    nfa = ce.last_fire_at(j.created_at - 1.second)
    lfa = ce.last_fire_at(nfa - 1.second)
    j.next_fire_at = nfa
    j.last_fire_at = lfa

    now = Time.now
    Time.stub!(:now).and_return(now)

    j.fired
    j.next_fire_at.should == ce.next_fire_at(now)
    j.last_fire_at.should == now
    j.status.should == SayWhen::BaseJob::STATE_WAITING
  end
end
