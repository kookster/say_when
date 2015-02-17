module SayWhen
  class Railtie < Rails::Railtie
    rake_tasks do
      require 'say_when/tasks'
    end
  end
end
