require 'say_when/base_job'
require 'say_when/store/active_record/job_execution'

module SayWhen
  module Store
    module ActiveRecord

      class Job  < ::ActiveRecord::Base

        include SayWhen::BaseJob

        self.table_name = "say_when_jobs"

        has_many  :triggers
        has_many  :job_executions
        serialize :data

        # default impl with some error handling and result recording
        def execute(trigger=nil)
          result = nil
          execution = SayWhen::Store::ActiveRecord::JobExecution.create(:job=>self, :status=>'executing', :start_at=>Time.now, :trigger=>trigger)

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
