require 'active_record'

require 'say_when/cron_expression'
require 'say_when/store/active_record/trigger'
require 'say_when/store/active_record/job'
require 'say_when/store/active_record/job_execution'
require 'say_when/store/active_record/acts'

module SayWhen
  module Store
    module ActiveRecord
      class Store

        include SayWhen::BaseStore
    
        def initialize(mutex=Mutex.new)
          super(mutex)
        end

        def add_trigger(trigger)
          @mutex.synchronize {
            trigger.save!
            trigger
          }
        end

        def remove_trigger(trigger)
          @mutex.synchronize {
            trigger.update_attribute(:status, SayWhen::Trigger::STATE_COMPLETE)
            trigger
          }
        end

        def add_job(job)
          @mutex.synchronize {
            job.save!
            job
          }
        end

        def remove_job(job)
          @mutex.synchronize {
            job.destroy!
            job
          }
        end

        def get(class_name, group, name)
      
          @mutex.synchronize {
            class_name = "SayWhen::" + class_name unless class_name.starts_with?('SayWhen::')
            class_name.constantize.find(:first, :conditions=>['`group` = ? and `name` = ?', group, name])
          }
        end

        def get_job_for_trigger(trigger)
          @mutex.synchronize {
            trigger.job
          }
        end

        def acquire_next_trigger(no_later_than)
          @mutex.synchronize {
           SayWhen::Trigger.transaction do
        
              # select and lock the next trigger that needs executin' (status waiting, and after no_later_than)
              next_trigger = SayWhen::Trigger.find( :first,
                                                    :lock=>true,
                                                    :order=>'next_fire_at ASC',
                                                    :conditions=>['status = ? and ? >= next_fire_at', 
                                                      SayWhen::Trigger::STATE_WAITING,
                                                      no_later_than.in_time_zone('UTC')])
                                    
              # make sure there is a trigger ready to run
              return nil if next_trigger.nil?
        
              # set status to acquired to take it out of rotation
              next_trigger.update_attribute(:status, SayWhen::Trigger::STATE_ACQUIRED)
        
              return next_trigger
            end
          }
        end

        def release_trigger(trigger)
          @mutex.synchronize {
            trigger.update_attribute(:status, SayWhen::Trigger::STATE_WAITING)
          }
        end

        def trigger_fired(trigger)
          @mutex.synchronize {
            trigger.fired
          }
        end

        def trigger_error(trigger, error)
          @mutex.synchronize {
            trigger.update_attribute(:status,SayWhen::Trigger::STATE_ERROR)
          }
        end
      end
    end
  end
end
