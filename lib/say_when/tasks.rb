# encoding: utf-8

namespace :say_when do
  desc 'Start the SayWhen Scheduler with Rails environment'
  task start_rails: :environment do
    require 'say_when'
    require 'say_when/poller/simple_poller'

    SayWhen::Poller::SimplePoller.new.start
  end

  desc 'Start the SayWhen Scheduler standalone'
  task :start do
    require 'say_when'
    require 'say_when/poller/simple_poller'

    SayWhen.configure
    puts "SayWhen starting with options: #{SayWhen.options.inspect}"
    SayWhen::Poller::SimplePoller.new.start
  end
end
