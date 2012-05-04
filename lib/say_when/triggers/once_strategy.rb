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

      def next_fire_at(time=Time.now)
        once_at if once_at >= time
      end
      
    end
  end
end