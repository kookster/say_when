$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'say_when'

require 'minitest'
require 'minitest/autorun'
require 'minitest/spec'
require 'minitest/mock'
require 'fileutils'

Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

require 'active_support'
require 'active_record'
if defined?(ActiveRecord)
  ActiveRecord::Base.logger = Logger.new('/dev/null')
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
