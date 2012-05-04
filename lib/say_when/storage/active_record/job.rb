require 'active_record'
require 'say_when/base_job'
require 'say_when/storage/active_record/job_execution'
require 'say_when/storage/active_record/acts'

module SayWhen
  module Storage
    module ActiveRecord

      class Job  < ::ActiveRecord::Base

        include SayWhen::BaseJob

        self.table_name = "say_when_jobs"

        serialize :trigger_options
        serialize :data
        has_many  :job_executions, :class_name=>'SayWhen::Storage::ActiveRecord::JobExecution'

        def self.acquire_next(no_later_than)
         SayWhen::Storage::ActiveRecord::Job.transaction do
            # select and lock the next trigger that needs executin' (status waiting, and after no_later_than)
            next_trigger = find(:first,
                                :lock       => true,
                                :order      => 'next_fire_at ASC',
                                :conditions => ['status = ? and ? >= next_fire_at', 
                                                STATE_WAITING,
                                                no_later_than.in_time_zone('UTC')])

            # make sure there is a trigger ready to run
            return nil if next_trigger.nil?
      
            # set status to acquired to take it out of rotation
            next_trigger.update_attribute(:status, STATE_ACQUIRED)
      
            return next_trigger
          end
        end

        def before_create
          self.status = STATE_WAITING
          self.next_fire_at = self.trigger.next_fire_at(Time.now)
        end

        def fired
          Job.transaction {
            super
            self.save!
          }
        end

        def release
          Job.transaction {
            super
            self.save!
          }
        end


        # default impl with some error handling and result recording
        def execute(trigger=nil)
          result = nil
          execution = SayWhen::Storage::ActiveRecord::JobExecution.create(:job=>self, :status=>'executing', :start_at=>Time.now, :trigger=>trigger)

          begin
            result = self.execute_job((data || {}).merge(:trigger=>trigger))
            execution.result = result
            execution.status = 'complete'
          rescue Object=>ex
            execution.result = "#{ex.class.name}: #{ex.message}\n\t#{ex.backtrace.join("\n\t")}"
            execution.status = 'error'
          end

          execution.end_at = Time.now
          execution.save!
          result
        end
        
      end
    
    end
  end
end
