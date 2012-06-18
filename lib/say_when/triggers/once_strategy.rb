require 'say_when/triggers/base'

module SayWhen
  module Triggers
    class OnceStrategy

      include SayWhen::Triggers::Base

      attr_accessor :once_at

      def initialize(options=nil)
        options ||= Time.now
        # if it's a hash, pull out the time
        @once_at = if options.is_a?(Time) || options.acts_like_time?
          options
        elsif options.is_a?(Hash) && options[:at]
          options[:at]
        else
          Time.now
        end
      
      end

      def next_fire_at(time=nil)
        nfa = once_at if (!time || (time <= once_at))
        puts "OnceStrategy: next_fire_at: #{nfa}, once_at: #{once_at}, time: #{time}"
        return nfa
      end
      
    end
  end
end