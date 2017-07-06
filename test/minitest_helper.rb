# encoding: utf-8

ENV['RAILS_ENV'] ||= 'test'
ENV['CELLULOID_BACKPORTED'] ||= 'false'

require 'simplecov'
SimpleCov.start #'rails'

if ENV['TRAVIS']
  require 'coveralls'
  Coveralls.wear!
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'say_when'

require 'minitest'
require 'minitest/autorun'
require 'minitest/spec'
require 'minitest/mock'
require 'fileutils'

require 'active_support'
require 'active_job'

require 'celluloid/test'

ActiveJob::Base.queue_adapter = :inline

Celluloid.boot

SayWhen.configure do |options|
  options[:storage_strategy]   = :memory
  options[:processor_strategy] = :test
end

SayWhen.logger = Logger.new('/dev/null')

module SayWhen
  module Test
    class TestTask
      @@executed = false

      def self.reset
        @@executed = false
      end

      def self.execute(data)
        @@executed = true
        data[:result] || 0
      end

      def self.executed?
        @@executed
      end
    end

    class TestActsAsScheduled
      @@_has_many = false

      def self.has_many_called?
        @@_has_many
      end

      def self.has_many(*args)
        @@_has_many = true
      end

      require 'say_when/storage/active_record_strategy'
      include SayWhen::Storage::ActiveRecordStrategy::Acts
      acts_as_scheduled
    end
  end
end
