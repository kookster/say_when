# encoding: utf-8

require 'minitest_helper'
require 'active_record_helper'
require 'say_when/storage/active_record_strategy'

describe SayWhen::Storage::ActiveRecordStrategy do

  let(:valid_attributes) {
    {
      trigger_strategy: :cron,
      trigger_options: { expression: '0 0 12 ? * * *', time_zone: 'Pacific Time (US & Canada)' },
      data:            { foo: 'bar', result: 1 },
      job_class:       'SayWhen::Test::TestTask',
      job_method:      'execute'
    }
  }

  let(:strategy) { SayWhen::Storage::ActiveRecordStrategy }

  let(:job) { strategy.create(valid_attributes) }

  it 'job can be created' do
    j = strategy.create(valid_attributes)
    j.wont_be_nil
  end

  it 'can execute the task for the job' do
    job.execute_job( { result: 1 } ).must_equal 1
  end

  it 'can execute the job' do
    j = strategy.create(valid_attributes)
    j.execute.must_equal 1
  end

  it 'derives a trigger from the attributes' do
    t = SayWhen::Storage::ActiveRecordStrategy::Job.create(valid_attributes)
    t.trigger.wont_be_nil
    t.trigger.must_be_instance_of SayWhen::Triggers::CronStrategy
  end

  it 'has a waiting state on create' do
    t = SayWhen::Storage::ActiveRecordStrategy::Job.create(valid_attributes)
    t.status.must_equal SayWhen::Storage::BaseJob::STATE_WAITING
  end

  it 'has a next fire at set on create' do
    opts = valid_attributes[:trigger_options]
    ce = SayWhen::CronExpression.new(opts[:expression], opts[:time_zone])
    j = SayWhen::Storage::ActiveRecordStrategy::Job.create(valid_attributes)
    j.status.must_equal SayWhen::Storage::BaseJob::STATE_WAITING
    j.next_fire_at.must_equal ce.next_fire_at
  end

  it 'can find the next job' do
    SayWhen::Storage::ActiveRecordStrategy::Job.delete_all
    j2_opts = {
      trigger_strategy: :cron,
      trigger_options:  { expression: '0 0 10 ? * * *', time_zone: 'Pacific Time (US & Canada)' },
      data:             { foo: 'bar', result: 2 },
      job_class:        'SayWhen::Test::TestTask',
      job_method:       'execute'
    }

    now = Time.now.change(hour: 0)
    Time.stub(:now, now) do
      j1 = SayWhen::Storage::ActiveRecordStrategy::Job.create(valid_attributes)
      j2 = SayWhen::Storage::ActiveRecordStrategy::Job.create(j2_opts)

      next_job = SayWhen::Storage::ActiveRecordStrategy::Job.acquire_next(2.days.since)
      next_job.must_equal j2
    end
  end

  it 'can be fired' do
    opts = valid_attributes[:trigger_options]
    ce = SayWhen::CronExpression.new(opts[:expression], opts[:time_zone])
    j = SayWhen::Storage::ActiveRecordStrategy::Job.create(valid_attributes)
    nfa = ce.last_fire_at(j.created_at - 1.second)
    lfa = ce.last_fire_at(nfa - 1.second)
    j.next_fire_at = nfa
    j.last_fire_at = lfa

    now = Time.now
    Time.stub(:now, now) do
      j.fired
      j.next_fire_at.must_equal ce.next_fire_at(now)
      j.last_fire_at.must_equal now
      j.status.must_equal SayWhen::Storage::BaseJob::STATE_WAITING
    end
  end
end
