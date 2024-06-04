# encoding: utf-8
require 'minitest_helper'
require 'say_when/poller/base_poller'

describe SayWhen::Poller::BasePoller do

  class TestPoller; include(SayWhen::Poller::BasePoller); end

  let (:poller) { TestPoller.new }
  let (:time_now) { Time.now }

  it 'handles errors' do
    job = Minitest::Mock.new
    job.expect(:release, true)
    err = nil
    begin
      raise RuntimeError.new('bad')
    rescue RuntimeError => ex
      err = ex
    end

    poller.job_error("oh noes", job, err)
  end

  it "can acquire a job" do
    poller.acquire(time_now)
  end

  it "can process a job" do
    job = Minitest::Mock.new
    job.expect(:fired, true, [Object])
    poller.process(job, time_now)
  end

  it "can process jobs" do
    poller.process_jobs
  end

  it "defines an error tick length" do
    expect(poller.error_tick_length).must_equal 0
  end
end
