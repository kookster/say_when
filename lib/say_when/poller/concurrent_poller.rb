# encoding: utf-8

require 'concurrent'
require 'logger'
require 'say_when/poller/base_poller'

module SayWhen
  module Poller
    class ConcurrentPoller
      include SayWhen::Poller::BasePoller

      def initialize(tick = nil)
        @tick_length = tick.to_i if tick
        start
      end

      def start
        @tick_timer = Concurrent::TimerTask.new(execution_interval: tick_length) do
          process_jobs
        end.tap(&:execute)
      end

      def stop
        if @tick_timer
          @tick_timer.shutdown
          @tick_timer = nil
        end
      end
    end
  end
end
