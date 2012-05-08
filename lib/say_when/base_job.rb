module SayWhen
  module BaseJob

    # ready to be run, just waiting for its turn
    STATE_WAITING = 'waiting'

    # has been acquired b/c it is time to be triggered
    STATE_ACQUIRED = 'acquired'

    # # related job for the trigger is executing
    # STATE_EXECUTING = 'executing'

    # "Complete" means the trigger has no remaining fire times
    STATE_COMPLETE = 'complete'

    # A Trigger arrives at the error state when the scheduler
    # attempts to fire it, but cannot due to an error creating and executing
    # its related job.
    STATE_ERROR = 'error'

    def lock
      @_lock ||= Mutex.new
    end

    def trigger
      @trigger ||= load_trigger
    end

    def fired
      self.lock.synchronize {
        fired = Time.now
        next_fire = self.trigger.next_fire_at(fired) rescue nil
        self.last_fire_at = fired
        self.next_fire_at = next_fire

        if next_fire.nil?
          self.status = STATE_COMPLETE
        else
          self.status = STATE_WAITING
        end
      }
    end

    def release
      self.lock.synchronize {
        if self.status == STATE_ACQUIRED
          self.status = STATE_WAITING
        end
      }
    end

    def execute
      self.execute_job(data)
    end

    def load_trigger
      strategy = trigger_strategy || :once
      require "say_when/triggers/#{strategy}_strategy"
      trigger_class_name = "SayWhen::Triggers::#{strategy.to_s.camelize}Strategy"
      trigger_class = trigger_class_name.constantize
      trigger_class.new(trigger_options)
    end

    def execute_job(options={})
      task_method = (self.job_method || 'execute').to_s
      task = get_task(task_method)
      task.send(task_method, options)
    end

    def get_task(task_method)
      task = nil

      if self.job_class
        tc = self.job_class.constantize
        if tc.respond_to?(task_method)
          task = tc
        else
          to = tc.new
          if to.respond_to?(task_method)
            task = to
          else
            raise "Neither '#{self.job_class}' class nor instance respond to '#{task_method}'"
          end
        end
      elsif self.scheduled
        if self.scheduled.respond_to?(task_method)
          task = self.scheduled
        else
          raise "Scheduled '#{self.scheduled.inspect}' does not respond to '#{task_method}'"
        end
      end
    end

  end
end
