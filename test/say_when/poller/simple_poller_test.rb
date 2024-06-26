# encoding: utf-8
require 'minitest_helper'
require 'say_when/poller/simple_poller'

describe SayWhen::Poller::SimplePoller do

  let (:poller) { SayWhen::Poller::SimplePoller.new }

  it 'should instantiate the poller' do
    expect(poller).wont_be_nil
  end

  it 'can check if poller is running' do
    expect(poller).wont_be :running?
  end

  it 'should start the poller running, and can stop it' do
    expect(poller).wont_be :running

    Thread.start{ poller.start }
    sleep(0.2)
    expect(poller).must_be :running

    poller.stop
    expect(poller).wont_be :running
  end
end
