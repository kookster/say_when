require 'say_when/triggers/base'

module SayWhen
  module Triggers
    class InstanceStrategy

      include SayWhen::Triggers::Base

      attr_accessor :instance, :next_at_method

      def initialize(options={})
        super
        @instance       = @job.scheduled
        @next_at_method = options[:next_at_method] || 'next_fire_at'
      end

      def next_fire_at(time=Time.now)
        instance.send(next_at_method, time)
      end

    end
  end
end
