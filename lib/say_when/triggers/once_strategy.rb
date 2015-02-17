# encoding: utf-8

require 'say_when/triggers/base'

module SayWhen
  module Triggers
    class OnceStrategy

      include SayWhen::Triggers::Base

      attr_accessor :once_at

      def initialize(options=nil)
        super
        self.once_at = options[:at] || Time.now
      end

      def next_fire_at(time=nil)
        nfa = once_at if (!time || (time <= once_at))
        return nfa
      end
    end
  end
end
