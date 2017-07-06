# encoding: utf-8

require 'celluloid/current'
require 'logger'
require 'say_when/poller/base_poller'

module SayWhen
  module Poller
    class CelluloidPoller
      include Celluloid
      include SayWhen::Poller::BasePoller

      def initialize(tick = nil)
        @tick_length = tick.to_i if tick
        start
      end

      def start
        @tick_timer = every(tick_length) { process_jobs }
      end

      def stop
        if @tick_timer
          @tick_timer.cancel
          @tick_timer = nil
        end
      end
    end
  end
end
