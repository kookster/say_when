require 'active_record'

module SayWhen
  module Storage
    module ActiveRecord

      class JobExecution  < ::ActiveRecord::Base

        self.table_name = "say_when_job_executions"
        
        belongs_to :job, :class_name=>'SayWhen::Storage::ActiveRecord::Job'
        belongs_to :trigger, :class_name=>'SayWhen::Storage::ActiveRecord::Trigger'

      end

    end
  end
end