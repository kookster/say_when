module SayWhen
  module Store
    module ActiveRecord

      # define a trigger class
      class Trigger < ::ActiveRecord::Base
        set_table_name "say_when_triggers"
        belongs_to :job
        belongs_to :scheduled, :polymorphic=>true
        serialize :data

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

        def fired
          raise "gotta implement this in subclasses"
        end
  
        def <=>(trigger)
          self.next_fire_at.to_i <=> trigger.next_fire_at.to_i
        end
      end

    end
  end
end
