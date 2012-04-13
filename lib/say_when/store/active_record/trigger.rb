module SayWhen
  module Store
    module ActiveRecord

      # define a trigger class
      class Trigger < ::ActiveRecord::Base

        set_table_name "say_when_triggers"

        belongs_to :job
        belongs_to :scheduled, :polymorphic=>true

        serialize :data

        composed_of :cron_expression, :class_name=>'SayWhen::CronExpression', :mapping=>[[:expression, :expression], [:time_zone, :time_zone]]
  
        def self.define(options)
          ce = CronExpression.new(options.delete(:cron_expression), options.delete(:time_zone))
          ct = CronTrigger.new(options)
          ct.cron_expression = ce
          ct.scheduled = options.delete(:scheduled)
          ct
        end

        def before_create
          self.status = STATE_WAITING
          self.next_fire_at = self.cron_expression.next_fire_at(Time.now)
        end

        def fired
          CronTrigger.transaction {
            fired = Time.now
            self.lock!
            next_fire = self.cron_expression.next_fire_at(fired)
            self.last_fire_at = fired
            self.next_fire_at = next_fire

            if next_fire.nil?
              self.status = STATE_COMPLETE
            else
              self.status = STATE_WAITING
            end
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
