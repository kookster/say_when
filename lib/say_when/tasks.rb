# encoding: utf-8

namespace :say_when do
  desc 'Start the SayWhen Scheduler'
  task start: :environment do
    require 'say_when'
    require 'say_when/poller/simple_poller'

    SayWhen::Poller::SimplePoller.start
  end
end
