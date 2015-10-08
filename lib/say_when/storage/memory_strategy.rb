require 'active_record'
require 'say_when/storage/base_job'

module SayWhen
  module Storage
    class MemoryStrategy

      class << self
        def acquire_next(no_later_than = nil)
          SayWhen::Storage::MemoryStrategy::Job.acquire_next(no_later_than)
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

          def acquire_next(no_later_than)
            acquire_lock.synchronize {
              next_job = jobs.detect(nil) do |j|
                (j.status == STATE_WAITING) && (j.next_fire_at.to_i <= no_later_than.to_i)
              end
              next_job.status = STATE_ACQUIRED if next_job
              next_job
            }
          end

          def create(job)
            new(job).save
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
        has_properties :job_class, :job_method, :data

        def initialize(options={})
          options.each do |k,v|
            if self.class.props.member?(k.to_s)
              send("#{k}=", v)
            end
          end

          self.status = STATE_WAITING unless self.status
          self.next_fire_at = trigger.next_fire_at
        end

        def to_hash
          [:job_class, :job_method, :data].inject({}){|h,k| h[k] = send(k); h }
        end

        def save
          self.class.jobs << self
          self
        end

        def <=>(job)
          self.next_fire_at.to_i <=> job.next_fire_at.to_i
        end

        def scheduled
          nil
        end
      end
    end
  end
end
