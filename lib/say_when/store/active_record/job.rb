module SayWhen
  module Store
    module ActiveRecord

      class Job  < ::ActiveRecord::Base

        include SayWhen::BaseJob

        set_table_name "say_when_jobs"
        has_many :triggers
        has_many :job_executions
        serialize :data

        # default impl with some error handling and result recording
        def execute(trigger)
          begin
            execution = JobExecution.create(:job=>self, :status=>'executing', :start_at=>Time.now)

            execution.result = execute_job
            execution.status = 'complete'
          rescue Object=>ex
            execution.result = "#{ex.class.name}: #{ex.message}\n\t#{ex.backtrace.join("\n\t")}"
            execution.status = 'error'
          end

          execution.end_at = Time.now
          execution.save!
        end
    
        # def execute_job
        #   tm = (self.job_method || 'execute').to_sym
        #   tc = self.job_class.constantize
        #   task = if tc.respond_to?(tm)
        #     tc
        #   else
        #     to = tc.new
        #     if to.respond_to?(tm)
        #       to
        #     else
        #       raise "Neither #{self.job_class} class nor instance respond to #{tm}"
        #     end
        #   end

        #   task.send(tm, data)
        # end

      end
    
    end
  end
end
