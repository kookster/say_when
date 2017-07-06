# encoding: utf-8

require 'say_when/triggers/base'
require 'say_when/cron_expression'

module SayWhen
  module Triggers
    class CronStrategy
      include SayWhen::Triggers::Base

      attr_accessor :cron_expression

      def initialize(options = {})
        super
        self.cron_expression = SayWhen::CronExpression.new(options)
      end

      def next_fire_at(time = nil)
        cron_expression.next_fire_at(time || Time.now)
      end
    end
  end
end
