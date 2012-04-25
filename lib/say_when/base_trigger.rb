module SayWhen
  module BaseTrigger
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

    def fired
      self.lock.synchronize {
        fired = Time.now
        next_fire = self.cron_expression.next_fire_at(fired)
        self.last_fire_at = fired
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
