require 'say_when/triggers/base'

module SayWhen
  module Triggers
    class ScheduledStrategy

      include SayWhen::Triggers::Base

      attr_accessor :scheduled, :next_at_method

      def initialize(options={})
        @scheduled       = @job.scheduled
        @next_at_method  = options[:next_at_method] || 'next_fire_at'
      end

      def next_fire_at(time=Time.now)
        scheduled.send(next_at_method, time)
      end

    end
  end
end
