require 'active_support/all'

require "say_when/version"
require 'say_when/store'
require 'say_when/processor'
require 'say_when/scheduler'

require 'say_when/cron_expression'

require 'say_when/store/memory_store'

if defined?(ActiveRecord)
  require 'say_when/store/active_record_store'
end

require 'say_when/simple_processor'

if defined?(ActiveMessaging)
  require 'say_when/active_messaging_processor' 
end

module SayWhen
  
  def SayWhen.logger
    unless defined?(@@logger)
      @@logger = Rails.logger if defined?(Rails.logger) && Rails.logger
      @@logger = Logger.new(STDOUT) unless defined?(@@logger)
    end
    @@logger
  end
end
