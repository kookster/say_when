# encoding: utf-8

require 'minitest_helper'

describe SayWhen::Scheduler do

  let (:scheduler) { SayWhen::Scheduler.new }

  it 'has a logger' do
    scheduler.logger.must_be_instance_of Logger
  end

  it 'extracts data' do
    scheduler.extract_data({}).must_be_nil
    scheduler.extract_data(data: 'data').must_equal 'data'
  end

  it 'extracts job method' do
    scheduler.extract_job_method({}).must_equal 'execute'
    scheduler.extract_job_method(job_method: 'just_doit').must_equal 'just_doit'
    scheduler.extract_job_method(method: 'doit').must_equal 'doit'
  end

  it 'extracts job class' do
    scheduler.extract_job_class(job_class: 'foo').must_equal 'foo'
    scheduler.extract_job_class(class: 'foo').must_equal 'foo'
    scheduler.extract_job_class(SayWhen::Test::TestTask).must_equal 'SayWhen::Test::TestTask'
    scheduler.extract_job_class('SayWhen::Test::TestTask').must_equal 'SayWhen::Test::TestTask'

    lambda do
      scheduler.extract_job_class(bar: 'foo')
    end.must_raise RuntimeError
  end

  it 'gets job options' do
    keys = [:job_class, :job_method, :data]
    opts = scheduler.job_options(keys.inject({}) { |s, k| s[k] = k.to_s; s } )
    keys.each{|k| opts[k].must_equal k.to_s }
  end

  it 'can schedule a new job' do
    job = scheduler.schedule(
      trigger_strategy: 'once',
      trigger_options: { at: 10.second.since },
      job_class: 'SayWhen::Test::TestTask',
      job_method: 'execute'
    )
    job.wont_be_nil
  end

  it 'can schedule a cron job' do
    job = scheduler.schedule_cron("0 0 12 ? * * *", SayWhen::Test::TestTask)
    job.wont_be_nil
  end

  it 'should provide the storage strategy' do
    scheduler.storage.must_equal SayWhen::Storage::MemoryStrategy
  end
end
