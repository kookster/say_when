# encoding: utf-8

require 'minitest_helper'
require 'say_when/storage/memory_strategy'

describe SayWhen::Storage::MemoryStrategy do

  let(:valid_attributes) {
    {
      trigger_strategy: :cron,
      trigger_options: { expression: '0 0 12 ? * * *', time_zone: 'Pacific Time (US & Canada)' },
      :name       => 'Memory::Job::Test',
      :group      => 'Test',
      :data       => { foo: 'bar', result: 1 },
      :job_class  => 'SayWhen::Test::TestTask',
      :job_method => 'execute'
    }
  }

  let(:strategy) { SayWhen::Storage::MemoryStrategy }

  let(:job) { strategy.create(valid_attributes) }

  it 'job can be created' do
    j = strategy.create(valid_attributes)
    expect(j).wont_be_nil
  end

  it 'can execute the task for the job' do
    expect(job.execute_job( { result: 1 } )).must_equal 1
  end

  it 'can execute the job' do
    j = strategy.create(valid_attributes)
    expect(j.execute).must_equal 1
  end

  it 'can serialize' do
    j = strategy.create(valid_attributes)
    expect(j.to_hash[:job_class]).must_equal 'SayWhen::Test::TestTask'
  end

  it 'can acquire and release the next job' do
    j = strategy.create(valid_attributes)
    expect(j).wont_be_nil
    next_job  = strategy.acquire_next(2.days.since)
    expect(next_job).wont_be_nil
    expect(next_job.status).must_equal "acquired"
    strategy.release(next_job)
    expect(next_job.status).must_equal "waiting"
  end

  it 'can reset acquired jobs' do
    j = strategy.create(valid_attributes)
    j.status = 'acquired'
    j.updated_at = 2.hours.ago
    strategy.reset_acquired(3600)
    expect(j.status).must_equal 'waiting'
  end

  it 'can be fired' do
    opts = valid_attributes[:trigger_options]
    ce = SayWhen::CronExpression.new(opts[:expression], opts[:time_zone])
    j = strategy.create(valid_attributes)
    nfa = ce.last_fire_at(j.updated_at - 1.second)
    lfa = ce.last_fire_at(nfa - 1.second)
    j.next_fire_at = nfa
    j.last_fire_at = lfa

    now = Time.now
    Time.stub(:now, now) do
      strategy.fired(j, now)
      expect(j.next_fire_at).must_equal ce.next_fire_at(now)
      expect(j.last_fire_at).must_equal now
      expect(j.status).must_equal SayWhen::Storage::BaseJob::STATE_WAITING
    end
  end

  it "can be serialized to a hash" do
    j = strategy.create(valid_attributes)
    expect(strategy.serialize(j).class).must_equal Hash
  end

  it "can be deserialized from a hash" do
    j = strategy.deserialize(valid_attributes)
    expect(j.class).must_equal SayWhen::Storage::MemoryStrategy::Job
  end

  it "can reset acquired jobs" do
    j = strategy.create(valid_attributes)
    j.status = 'acquired'
    j.updated_at = 2.hours.ago
    SayWhen::Storage::MemoryStrategy::Job.reset_acquired(3600)
    expect(j.status).must_equal 'waiting'
  end
end
