# encoding: utf-8

require 'active_support/all'

require 'say_when/version'
require 'say_when/configuration'
require 'say_when/utils'
require 'say_when/cron_expression'
require 'say_when/scheduler'

require 'say_when/railtie' if defined?(Rails)

module SayWhen
  class << self

    def logger
      @logger ||= if defined?(Rails)
        Rails.logger
      else
        Logger.new(STDOUT)
      end
    end

    def logger=(l)
      @logger = l
    end

    def options
      @options ||= SayWhen::Configuration.default_options
    end

    def configure(opts = {})
      @lock ||= Mutex.new
      options.merge(opts)
      yield options if block_given?
    end

    def scheduler
      return @scheduler if @scheduler
      @lock.synchronize { @scheduler = SayWhen::Scheduler.new if @scheduler.nil? }
      @scheduler
    end

    def schedule(job)
      scheduler.schedule(job)
    end
  end
end
