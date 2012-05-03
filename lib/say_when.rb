require 'active_support'

require "say_when/version"
require 'say_when/base_job'
require 'say_when/cron_expression'
require 'say_when/processor/base'
require 'say_when/processor/simple'
require 'say_when/processor/active_messaging' if defined?(ActiveMessaging)
require 'say_when/scheduler'


module SayWhen
  
  def SayWhen.logger
    unless defined?(@@logger)
      @@logger = Rails.logger if defined?(Rails.logger) && Rails.logger
      @@logger = Logger.new(STDOUT) unless defined?(@@logger)
    end
    @@logger
  end

end
