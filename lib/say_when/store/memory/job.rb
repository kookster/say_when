module SayWhen
  module Store
    module Memory

      # define a trigger class
      class Job

      	include SayWhen::BaseJob

      	attr_accessor :triggers, :name, :group, :data, :job_class, :job_method

      end

    end
  end
end
