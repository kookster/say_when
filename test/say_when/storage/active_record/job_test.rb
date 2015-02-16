require 'minitest_helper'
require 'active_record_helper'
require 'say_when/storage/active_record/job'

describe SayWhen::Storage::ActiveRecord::Job do

  let(:valid_attributes) {
    {
      trigger_strategy: :cron,
      trigger_options: { expression: '0 0 12 ? * * *', time_zone: 'Pacific Time (US & Canada)' },
      data:            { foo: 'bar', result: 1 },
      job_class:       'SayWhen::Test::TestTask',
      job_method:      'execute'
    }
  }

  it 'can be instantiated' do
    j = SayWhen::Storage::ActiveRecord::Job.create!(valid_attributes)
    j.wont_be_nil
  end

  it 'can execute the task for the job' do
    j = SayWhen::Storage::ActiveRecord::Job.create(valid_attributes)
    j.execute_job( { result: 1 } ).must_equal 1
  end

  it 'can execute the job' do
    j = SayWhen::Storage::ActiveRecord::Job.create(valid_attributes)
    j.execute.must_equal 1
  end

  it 'derives a trigger from the attributes' do
    t = SayWhen::Storage::ActiveRecord::Job.create(valid_attributes)
    t.trigger.wont_be_nil
    t.trigger.should be_a SayWhen::Triggers::CronStrategy
  end

  it 'has a waiting state on create' do
    t = SayWhen::Storage::ActiveRecord::Job.create(valid_attributes)
    t.status.must_equal SayWhen::BaseJob::STATE_WAITING
  end

  it 'has a next fire at set on create' do
    opts = valid_attributes[:trigger_options]
    ce = SayWhen::CronExpression.new(opts[:expression], opts[:time_zone])
    j = SayWhen::Storage::ActiveRecord::Job.create(valid_attributes)
    j.status.must_equal SayWhen::BaseJob::STATE_WAITING
    j.next_fire_at.must_equal ce.next_fire_at
  end

  it 'can find the next job' do
    j2_opts = {
      trigger_strategy: :cron,
      trigger_options:  { expression: '0 0 10 ? * * *', time_zone: 'Pacific Time (US & Canada)' },
      data:             { foo: 'bar', result: 2 },
      job_class:        'SayWhen::Test::TestTask',
      job_method:       'execute'
    }

    j1 = SayWhen::Storage::ActiveRecord::Job.create(valid_attributes)
    j2 = SayWhen::Storage::ActiveRecord::Job.create(j2_opts)
    next_job = SayWhen::Storage::ActiveRecord::Job.acquire_next(1.day.since)
    next_job.must_equal j2
  end

  it 'can be fired' do
    opts = valid_attributes[:trigger_options]
    ce = SayWhen::CronExpression.new(opts[:expression], opts[:time_zone])
    j = SayWhen::Storage::ActiveRecord::Job.create(valid_attributes)
    nfa = ce.last_fire_at(j.created_at - 1.second)
    lfa = ce.last_fire_at(nfa - 1.second)
    j.next_fire_at = nfa
    j.last_fire_at = lfa

    now = Time.now
    Time.stub!(:now).and_return(now)

    j.fired
    j.next_fire_at.must_equal ce.next_fire_at(now)
    j.last_fire_at.must_equal now
    j.status.must_equal SayWhen::BaseJob::STATE_WAITING
  end
end
