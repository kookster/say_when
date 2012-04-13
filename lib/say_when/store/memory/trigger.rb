module SayWhen
  module Store
    module Memory

      # define a trigger class
      class Trigger

      	include SayWhen::BaseTrigger

        @@lock = Mutex.new

      	attr_accessor :job, :type, :name, :group, :data, :expression, :time_zone
      	attr_accessor :status, :is_paused, :is_blocked, :last_fire_at, :next_fire_at, :start_at, :end_at
      	attr_accessor :scheduled
        attr_accessor :cron_expression
  
        def initialize(options={})
          if options[:cron_expression] && options[:time_zone]
            self.cron_expression = CronExpression.new(options.delete(:cron_expression), options.delete(:time_zone))
            self.next_fire_at = self.cron_expression.next_fire_at(Time.now)
          end
          self.scheduled = options.delete(:scheduled)
          self.status = STATE_WAITING
        end

        def fired
          @@lock.synchronize {
            self.last_fire_at = Time.now
            fired_at = 
            next_fire = self.cron_expression.next_fire_at(fired_at)
            self.next_fire_at = next_fire

            if next_fire.nil?
              self.status = STATE_COMPLETE
            else
              self.status = STATE_WAITING
            end
          }
        end

      end

    end
  end
end


