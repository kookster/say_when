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

  it 'job can be serialized' do
    strategy.serialize(job).must_equal job
    strategy.deserialize(job).must_equal job
  end

  it 'can execute the task for the job' do
    job.execute_job( { result: 1 } ).must_equal 1
  end

  it 'can execute the job' do
    j = strategy.create(valid_attributes)
    j.execute.must_equal 1
  end

  it 'derives a trigger from the attributes' do
    t = strategy.create(valid_attributes)
    t.trigger.wont_be_nil
    t.trigger.must_be_instance_of SayWhen::Triggers::CronStrategy
  end

  it 'has a waiting state on create' do
    t = strategy.create(valid_attributes)
    t.status.must_equal SayWhen::Storage::BaseJob::STATE_WAITING
  end

  it 'has a next fire at set on create' do
    opts = valid_attributes[:trigger_options]
    ce = SayWhen::CronExpression.new(opts[:expression], opts[:time_zone])
    j = strategy.create(valid_attributes)
    j.status.must_equal SayWhen::Storage::BaseJob::STATE_WAITING
    j.next_fire_at.must_equal ce.next_fire_at
  end

  it 'can acquire and release the next job' do
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
      j1 = strategy.create(valid_attributes)
      j1.wont_be_nil
      j2 = strategy.create(j2_opts)

      next_job = strategy.acquire_next(2.days.since)
      next_job.status.must_equal "acquired"
      next_job.must_equal j2
      strategy.release(next_job)
      next_job.status.must_equal "waiting"
    end
  end

  it 'resets acquired jobs' do
    old = 2.hours.ago
    j = strategy.create(valid_attributes)
    j.update_attributes(status: 'acquired', updated_at: old, created_at: old)

    j.status.must_equal 'acquired'

    strategy.reset_acquired(3600)

    j.reload
    j.status.must_equal 'waiting'
  end

  it 'can be fired' do
    opts = valid_attributes[:trigger_options]
    ce = SayWhen::CronExpression.new(opts[:expression], opts[:time_zone])
    j = strategy.create(valid_attributes)
    nfa = ce.last_fire_at(j.created_at - 1.second)
    lfa = ce.last_fire_at(nfa - 1.second)
    j.next_fire_at = nfa
    j.last_fire_at = lfa

    now = Time.now
    Time.stub(:now, now) do
      strategy.fired(j, now)
      j.next_fire_at.must_equal ce.next_fire_at(now)
      j.last_fire_at.must_equal now
      j.status.must_equal SayWhen::Storage::BaseJob::STATE_WAITING
    end
  end

  describe "acts_as_scheduled" do
    it "acts_as_scheduled calls has_many" do
      SayWhen::Test::TestActsAsScheduled.must_be :has_many_called?
    end

    it "includes schedule methods" do
      taas = SayWhen::Test::TestActsAsScheduled.new
      [:schedule, :schedule_instance, :schedule_cron, :schedule_once, :schedule_in].each do |m|
        taas.respond_to?(m).must_equal true
      end
    end

    it "sets the scheduled value" do
      taas = SayWhen::Test::TestActsAsScheduled.new
      job = taas.set_scheduled({})
      job[:scheduled].must_equal taas
    end
  end
end
