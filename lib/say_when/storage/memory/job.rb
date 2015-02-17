# encoding: utf-8

require 'say_when/storage/memory/base'

module SayWhen
  module Storage
    module Memory

      # define a trigger class
      class Job

        include SayWhen::Storage::Memory::Base
        include SayWhen::BaseJob

        has_properties :group, :name, :status, :start_at, :end_at
        has_properties :trigger_strategy, :trigger_options, :last_fire_at, :next_fire_at
        has_properties :job_class, :job_method, :data
        has_properties :scheduled

        cattr_accessor :jobs
        @@jobs = SortedSet.new
        @@acquire_lock = Mutex.new

        def self.acquire_next(no_later_than)
          @@acquire_lock.synchronize {

            next_job = jobs.detect(nil) do |j|
              (j.status == STATE_WAITING) && (j.next_fire_at.to_i <= no_later_than.to_i)
            end

            next_job.status = STATE_ACQUIRED if next_job
            next_job
          }
        end

        def self.create(job)
          job = new(job) if job.is_a?(Hash)
          self.jobs << job
        end

        def initialize(options={})
          super
          self.status = STATE_WAITING unless self.status
          self.next_fire_at = trigger.next_fire_at
        end

        def <=>(job)
          self.next_fire_at.to_i <=> job.next_fire_at.to_i
        end
      end
    end
  end
end
