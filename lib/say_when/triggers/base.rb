module SayWhen
  module Triggers
    module Base

      attr_accessor :job

      def initialize(options={})
        @job = options.delete(:job)
      end

      def next_fire_at(time=nil)
        raise NotImplementedError.new('You need to implement next_fire_at in your strategy')
      end

    end
  end
end