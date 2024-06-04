# encoding: utf-8

require 'minitest_helper'

describe SayWhen::Scheduler do

  let (:scheduler) { SayWhen::Scheduler.new }

  it 'has a logger' do
    expect(scheduler.logger).must_be_instance_of Logger
  end

  it 'extracts data' do
    expect(scheduler.extract_data({})).must_be_nil
    expect(scheduler.extract_data(data: 'data')).must_equal 'data'
  end

  it 'extracts job method' do
    expect(scheduler.extract_job_method({})).must_equal 'execute'
    expect(scheduler.extract_job_method(job_method: 'just_doit')).must_equal 'just_doit'
    expect(scheduler.extract_job_method(method: 'doit')).must_equal 'doit'
  end

  it 'extracts job class' do
    expect(scheduler.extract_job_class(job_class: 'foo')).must_equal 'foo'
    expect(scheduler.extract_job_class(class: 'foo')).must_equal 'foo'
    expect(scheduler.extract_job_class(SayWhen::Test::TestTask)).must_equal 'SayWhen::Test::TestTask'
    expect(scheduler.extract_job_class('SayWhen::Test::TestTask')).must_equal 'SayWhen::Test::TestTask'
  end

  it 'gets job options' do
    keys = [:job_class, :job_method, :data]
    opts = scheduler.job_options(keys.inject({}) { |s, k| s[k] = k.to_s; s } )
    keys.each{|k| expect(opts[k]).must_equal k.to_s }

    expect(lambda do
      scheduler.job_options(bar: 'foo')
    end).must_raise RuntimeError
  end

  it 'can schedule a new job' do
    job = scheduler.schedule(
      trigger_strategy: 'once',
      trigger_options: { at: 10.second.since },
      job_class: 'SayWhen::Test::TestTask',
      job_method: 'execute'
    )
    expect(job).wont_be_nil
  end

  it 'can schedule a cron job' do
    job = scheduler.schedule_cron("0 0 12 ? * * *", SayWhen::Test::TestTask)
    expect(job).wont_be_nil
  end

  it 'should provide the storage strategy' do
    expect(scheduler.storage).must_equal SayWhen::Storage::MemoryStrategy
  end
end
