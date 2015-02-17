require 'active_support'

require "say_when/version"
require 'say_when/base_job'
require 'say_when/cron_expression'
require 'say_when/processor/base'
require 'say_when/processor/simple'
require 'say_when/scheduler'

require 'say_when/processor/active_messaging' if defined?(::ActiveMessaging)
require 'say_when/processor/shoryuken' if defined?(::Shoryuken)
require 'say_when/storage/active_record/job' if defined?(::ActiveRecord)
require 'say_when/railtie' if defined?(Rails)

module SayWhen
  def SayWhen.logger=(logger)
    @@logger = logger
  end

  def SayWhen.logger
    if !defined?(@@logger) || !@@logger
      if defined?(Rails.logger) && Rails.logger
        @@logger = Rails.logger
      end

      @@logger = Logger.new(STDOUT) unless defined?(@@logger)
    end
    @@logger
  end
end
