# encoding: utf-8

module SayWhen
  module Triggers
    module Base
      attr_accessor :job

      def initialize(options = {})
        self.job = options.delete(:job)
        raise ArgumentError.new("job must be provided to create a trigger") unless job
      end

      def next_fire_at(time = nil)
        raise NotImplementedError.new('You need to implement next_fire_at in your strategy')
      end
    end
  end
end
