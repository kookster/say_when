require 'say_when/triggers/base'

module SayWhen
  module Triggers
    class OnceStrategy

      include SayWhen::Triggers::Base

      attr_accessor :once_at

      def initialize(options=nil)
        super
        @once_at = options[:at] || Time.now
      end

      def next_fire_at(time=nil)
        nfa = once_at if (!time || (time <= once_at))
        puts "OnceStrategy: next_fire_at: #{nfa}, once_at: #{once_at}, time: #{time}"
        return nfa
      end
      
    end
  end
end
