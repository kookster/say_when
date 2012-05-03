require 'say_when/store/memory/base'

module SayWhen
  module Store
    module Memory

      # define a trigger class
      class Job

        cattr_accessor :jobs
        @@jobs = SortedSet.new

        include SayWhen::Storage::Memory::Base
      	include SayWhen::BaseJob

        has_properties :status, :start_at, :end_at
        has_properties :trigger_strategy, :trigger_options, :last_fire_at, :next_fire_at
      	has_properties :job_class, :job_method, :data

        def self.acquire_next(no_later_than)
          self.lock.synchronize {
            
            next_job = jobs.detect(nil) do |j|
              (j.status == STATE_WAITING) && (j.next_fire_at.to_i <= no_later_than.to_i)
            end

            next_job.status = STATE_ACQUIRED if next_job
            next_job
          }          
        end

        def initialize(options={})
          super
          self.status = STATE_WAITING unless self.status          
          self.next_fire_at = self.trigger.next_fire_at(Time.now)
          self.class.jobs << self
        end

        def <=>(job)
          self.next_fire_at.to_i <=> job.next_fire_at.to_i
        end

      end

    end
  end
end
