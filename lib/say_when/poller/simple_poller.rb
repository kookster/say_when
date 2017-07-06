# encoding: utf-8

require 'say_when/poller/base_poller'

module SayWhen
  module Poller
    class SimplePoller
      include SayWhen::Poller::BasePoller

      attr_accessor :running

      def initialize(tick = nil)
        self.tick_length = tick.to_i if tick
        self.running = false
      end

      def running?
        !!running
      end

      def start
        self.running = true
        logger.info "SayWhen::SimplePoller started"
        while running
          process_jobs
          tick
        end
        logger.info "SayWhen::SimplePoller stopped"
      end

      def stop
        logger.info "SayWhen::SimplePoller stopping..."
        self.running = false
      end
    end
  end
end
