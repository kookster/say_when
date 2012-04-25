require 'say_when/store/memory/base'

module SayWhen
  module Store
    module Memory

      # define a trigger class
      class Trigger

        include SayWhen::Store::Memory::Base
      	include SayWhen::BaseTrigger

      	has_properties :job, :type, :name, :group, :data, :expression, :time_zone
      	has_properties :status, :is_paused, :is_blocked, :last_fire_at, :next_fire_at, :start_at, :end_at
      	has_properties :scheduled
        has_properties :cron_expression
  
        def initialize(options={})
          super
          self.status = STATE_WAITING unless self.status
          self.cron_expression = CronExpression.new(self.expression, self.time_zone) if self.expression
          self.next_fire_at = self.cron_expression.next_fire_at(Time.now) if self.cron_expression
        end

      end

    end
  end
end


