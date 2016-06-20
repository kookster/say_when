# encoding: utf-8

ENV['RAILS_ENV'] ||= 'test'

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

module SayWhen
  module Test
    class TestTask

      cattr_accessor :executed
      @@executed = false

      def execute(data)
        @@executed = true
        data[:result] || 0
      end
    end
  end
end

SayWhen.configure do |options|
  options[:storage_strategy]   = :memory
  options[:processor_strategy] = :test
end

SayWhen.logger = Logger.new('/dev/null')
