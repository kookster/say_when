# encoding: utf-8

require 'celluloid'
require 'say_when/poller/base_poller'

module SayWhen
  module Poller
    class CelluloidPoller
      include Celluloid
      include SayWhen::Poller::BasePoller

      def initialize(tick = nil)
        self.tick_length = tick.to_i if tick
        start
      end

      def start
        every(tick_length) { process_jobs }
      end
    end
  end
end
