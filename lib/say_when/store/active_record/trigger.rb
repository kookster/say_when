require 'say_when/base_trigger'
require 'say_when/cron_expression'

module SayWhen
  module Store
    module ActiveRecord

      # define a trigger class
      class Trigger < ::ActiveRecord::Base

        
        include SayWhen::BaseTrigger

        self.table_name = "say_when_triggers"

        belongs_to  :job
        belongs_to  :scheduled, :polymorphic=>true

        serialize   :data

        composed_of :cron_expression,
                    :class_name => 'SayWhen::CronExpression',
                    :mapping    => [[:expression, :expression], [:time_zone, :time_zone]],
                    :converter  => Proc.new{ |e| 
                      if e.is_a?(Hash)
                        SayWhen::CronExpression.new(e[:expression], e[:time_zone])
                      else
                        SayWhen::CronExpression.new(e.to_s)
                      end
                    }

        def before_create
          self.status = STATE_WAITING
          self.next_fire_at = self.cron_expression.next_fire_at(Time.now)
        end

        def fired
          Trigger.transaction {
            super
            self.save!
          }
        end

        def <=>(trigger)
          self.next_fire_at.to_i <=> trigger.next_fire_at.to_i
        end
      end

    end
  end
end
