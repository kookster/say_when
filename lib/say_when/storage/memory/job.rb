require 'say_when/storage/memory/base'

module SayWhen
  module Store
    module Memory

      # define a trigger class
      class Job

        cattr_accessor :jobs
        @@jobs = SortedSet.new

        include SayWhen::Storage::Memory::Base
      	include SayWhen::BaseJob

        has_properties :group, :name, :status, :start_at, :end_at
        has_properties :trigger_strategy, :trigger_options, :last_fire_at, :next_fire_at
        has_properties :job_class, :job_method, :data
        has_properties :scheduled
        has_properties :updated_at

        def self.class_lock
          @@_lock ||= Mutex.new
        end

        def self._reset
          @@jobs = SortedSet.new
        end

        def self.reset_acquired(older_than_seconds)
          return unless older_than_seconds.to_i > 0
          older_than = (Time.now - older_than_seconds.to_i)
          self.class_lock.synchronize {
            jobs.select do |j|
              j.status == STATE_ACQUIRED && j.updated_at < older_than
            end.each{ |j| j.status = STATE_WAITING }
          }
        end

        def self.acquire_next(no_later_than)
          self.class_lock.synchronize {

            next_job = jobs.detect(nil) do |j|
              (j.status == STATE_WAITING) && (j.next_fire_at.to_i <= no_later_than.to_i)
            end

            if next_job
              next_job.status = STATE_ACQUIRED
              next_job.updated_at = Time.now
            end

            next_job
          }
        end

        def initialize(options={})
          super
          self.updated_at = Time.now
          self.status = STATE_WAITING unless self.status
          self.next_fire_at = trigger.next_fire_at
          self.class.jobs << self
        end

        def <=>(job)
          self.next_fire_at.to_i <=> job.next_fire_at.to_i
        end

        def fired(fired_at=Time.now)
          super
          self.updated_at = Time.now
        end

        def release
          super
          self.updated_at = Time.now
        end
      end

    end
  end
end
