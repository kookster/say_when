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

    def fired(time=Time.now)
      raise NotImplementedError.new("Implement what to do to update the trigger state after it has been triggered.")
    end

  end
end
