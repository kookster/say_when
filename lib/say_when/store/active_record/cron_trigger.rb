module SayWhen
  module Store
    module ActiveRecord

      # define a trigger class
      # todo implement the options better
      class CronTrigger < Trigger

        composed_of :cron_expression, :class_name=>'SayWhen::CronExpression', :mapping=>[[:expression, :expression], [:time_zone, :time_zone]]

        def self.define(options)
          ce = CronExpression.new(options.delete(:cron_expression), options.delete(:time_zone))
          ct = CronTrigger.new(options)
          ct.cron_expression = ce
          ct.scheduled = options.delete(:scheduled)
          ct
        end

        def before_create
          self.status = Trigger::STATE_WAITING
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
              self.status = Trigger::STATE_COMPLETE
            else
              self.status = Trigger::STATE_WAITING
            end
            self.save!
          }
        end
      end

    end
  end
end
