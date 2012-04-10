module SayWhen
  module Store
    module ActiveRecord

      class JobExecution  < ::ActiveRecord::Base
        set_table_name "say_when_job_executions"
        belongs_to :job, :class_name=>'SayWhen::Job'
      end

    end
  end
end