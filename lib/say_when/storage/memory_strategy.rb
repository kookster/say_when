require 'active_record'
require 'say_when/storage/base_job'

module SayWhen
  module Storage
    class MemoryStrategy
      class << self
        def acquire_next(no_later_than = nil)
          SayWhen::Storage::MemoryStrategy::Job.acquire_next(no_later_than)
        end

        def reset_acquired(older_than_seconds)
          SayWhen::Storage::MemoryStrategy::Job.reset_acquired(older_than_seconds)
        end

        def fired(job, fired_at = Time.now)
          job.fired(fired_at)
        end

        def release(job)
          job.release
        end

        def create(job)
          SayWhen::Storage::MemoryStrategy::Job.create(job)
        end

        def serialize(job)
          job.to_hash
        end

        def deserialize(job)
          SayWhen::Storage::MemoryStrategy::Job.new(job)
        end
      end

      class Job
        include SayWhen::Storage::BaseJob

        class << self
          def acquire_lock
            @acquire_lock ||= Mutex.new
          end

          def jobs
            @jobs ||= SortedSet.new
          end

          def props
            @props ||= []
          end

          def reset_acquired(older_than_seconds)
            return unless older_than_seconds.to_i > 0
            older_than = (Time.now - older_than_seconds.to_i)
            acquire_lock.synchronize do
              jobs.select do |j|
                j.status == SayWhen::Storage::BaseJob::STATE_ACQUIRED && j.updated_at < older_than
              end.each{ |j| j.status = SayWhen::Storage::BaseJob::STATE_WAITING }
            end
          end

          def acquire_next(no_later_than)
            acquire_lock.synchronize do
              next_job = jobs.detect(nil) do |j|
                (j.status == SayWhen::Storage::BaseJob::STATE_WAITING) &&
                (j.next_fire_at.to_i <= no_later_than.to_i)
              end
              if next_job
                next_job.status = SayWhen::Storage::BaseJob::STATE_ACQUIRED
                next_job.updated_at = Time.now
              end
              next_job
            end
          end

          def create(job)
            if existing_job = find_named_job(job[:group], job[:name])
              self.jobs.delete(existing_job)
            end

            new(job).save
          end

          def find_named_job(group, name)
            group && name && jobs.detect { |j| j.group == group && j.name == name }
          end

          def has_properties(*args)
            args.each do |a|
              unless props.member?(a.to_s)
                props << a.to_s
                class_eval { attr_accessor(a.to_sym) }
              end
            end
          end
        end

        has_properties :group, :name, :status, :start_at, :end_at
        has_properties :trigger_strategy, :trigger_options, :last_fire_at, :next_fire_at
        has_properties :job_class, :job_method, :data, :updated_at, :scheduled

        def initialize(options = {})
          options.each do |k,v|
            if self.class.props.member?(k.to_s)
              send("#{k}=", v)
            end
          end

          self.updated_at = Time.now
          self.status = STATE_WAITING unless self.status
          self.next_fire_at = trigger.next_fire_at
        end

        def to_hash
          [:job_class, :job_method, :data].inject({}) { |h,k| h[k] = send(k); h }
        end

        def save
          self.class.jobs << self
          self
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
