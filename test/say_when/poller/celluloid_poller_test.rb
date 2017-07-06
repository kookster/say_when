# encoding: utf-8
require 'minitest_helper'
require 'say_when/poller/celluloid_poller'

describe SayWhen::Poller::CelluloidPoller do
  let (:poller) { SayWhen::Poller::CelluloidPoller.new(100) }

  it 'should instantiate the poller' do
    poller.tick_length.must_equal 100
  end

  it 'should start the poller running, and can stop it' do
    poller.start
    sleep(0.2)
    poller.stop
  end
end
