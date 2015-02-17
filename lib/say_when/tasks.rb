namespace :say_when do
  desc 'Start the SayWhen Scheduler'
  task start: :environment do
    require 'say_when'
    SayWhen::Scheduler.start
  end
end
