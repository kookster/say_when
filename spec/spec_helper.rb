ENV['RAILS_ENV']='test'

require "rubygems"
require 'bundler/setup'
require 'active_support'
require 'active_record'

require 'spec'
require 'spec/autorun'

$: << (File.dirname(__FILE__) + "/../lib")
require "say_when"

logger = Logger.new(STDOUT)
logger.level = Logger::ERROR
SayWhen.logger = logger
::ActiveRecord::Base.logger = logger

Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}


Spec::Runner.configure do |config|
  config.mock_with :rspec
end

module SayWhen
  module Test

    class TestTask
      def execute(data)
        data[:result] || 0
      end
    end

    class TestProcessor < SayWhen::Processor::Base
      attr_accessor :jobs

      def initialize(scheduler)
        super(scheduler)
        reset
      end

      def process(job)
        self.jobs << job
      end

      def reset
        self.jobs = []
      end
    end

  end
end
