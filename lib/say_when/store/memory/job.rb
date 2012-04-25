require 'say_when/store/memory/base'

module SayWhen
  module Store
    module Memory

      # define a trigger class
      class Job

        include SayWhen::Store::Memory::Base
      	include SayWhen::BaseJob

      	has_properties :triggers, :name, :group, :data, :job_class, :job_method

      end

    end
  end
end
