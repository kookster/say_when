namespace :say_when do
  task :setup

  desc "Start the SayWhen Scheduler"
  task :start => [ :preload ] do
    require 'say_when'
    SayWhen::Scheduler.start
  end

  # Preload app files if this is Rails
  # thanks resque
  task :preload => :setup do
    if defined?(Rails) && Rails.respond_to?(:application)
      # Rails 3
      Rails.application.eager_load!
    elsif defined?(Rails::Initializer)
      # Rails 2.3
      $rails_rake_task = false
      Rails::Initializer.run :load_application_classes
    end
  end
end