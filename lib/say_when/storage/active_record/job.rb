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
        belongs_to :scheduled, :polymorphic => true
        has_many  :job_executions, :class_name=>'SayWhen::Storage::ActiveRecord::JobExecution'
        before_create :set_defaults

        def self.acquire_next(no_later_than)
         SayWhen::Storage::ActiveRecord::Job.transaction do
            # select and lock the next job that needs executin' (status waiting, and after no_later_than)
            next_job = find(:first,
                            :lock       => true,
                            :order      => 'next_fire_at ASC',
                            :conditions => ['status = ? and ? >= next_fire_at', 
                                            STATE_WAITING,
                                            no_later_than.in_time_zone('UTC')])

            # make sure there is a job ready to run
            return nil if next_job.nil?
      
            # set status to acquired to take it out of rotation
            next_job.update_attribute(:status, STATE_ACQUIRED)
      
            return next_job
          end
        end

        def set_defaults
          # puts "SayWhen::Storage::ActiveRecord::Job - set_defaults start"
          self.status = STATE_WAITING
          self.next_fire_at = self.trigger.next_fire_at
          # puts "SayWhen::Storage::ActiveRecord::Job - set_defaults, next_fire_at: #{self.next_fire_at}"
        end

        def fired(fired_at=Time.now)
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
        def execute
          result = nil
          execution = SayWhen::Storage::ActiveRecord::JobExecution.create(:job=>self, :status=>'executing', :start_at=>Time.now)

          begin
            result = self.execute_job(data)
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
