require 'active_record'
require 'say_when/storage/base_job'

module SayWhen
  module Storage
    class ActiveRecordStrategy

      class << self
        def acquire_next(no_later_than = nil)
          SayWhen::Storage::ActiveRecordStrategy::Job.acquire_next(no_later_than)
        end

        def create(job)
          SayWhen::Storage::ActiveRecordStrategy::Job.create(job)
        end

        def fired(job, fired_at = Time.now)
          job.fired(fired_at)
        end

        def release(job)
          job.release
        end

        def serialize(job)
          job
        end

        def deserialize(job)
          job
        end
      end

      class JobExecution < ActiveRecord::Base
        self.table_name = 'say_when_job_executions'
        belongs_to :job, class_name: 'SayWhen::Storage::ActiveRecordStrategy::Job'
      end

      class Job < ActiveRecord::Base
        include SayWhen::Storage::BaseJob

        self.table_name = 'say_when_jobs'

        serialize :trigger_options
        serialize :data

        belongs_to :scheduled, polymorphic: true
        has_many  :job_executions, class_name: 'SayWhen::Storage::ActiveRecordStrategy::JobExecution'

        before_create :set_defaults

        def self.acquire_next(no_later_than = nil)
          next_job = nil
          no_later_than = (no_later_than || Time.now).in_time_zone('UTC')

          hide_logging do
            SayWhen::Storage::ActiveRecordStrategy::Job.transaction do
              # select and lock the next job that needs executin' (status waiting, and after no_later_than)
              next_job = where(status: STATE_WAITING).
                         where('next_fire_at < ?', no_later_than).
                         order('next_fire_at ASC').
                         lock(true).
                         first

              # set status to acquired to take it out of rotation
              next_job.update_attribute(:status, STATE_ACQUIRED) if next_job
            end
          end
          next_job
        end

        def self.hide_logging
          old_logger = nil
          begin
            old_logger = ::ActiveRecord::Base.logger
            ::ActiveRecord::Base.logger = nil
            yield
          ensure
            ::ActiveRecord::Base.logger = old_logger
          end
        end

        def set_defaults
          self.status = STATE_WAITING
          self.next_fire_at = self.trigger.next_fire_at
        end

        def fired(fired_at=Time.now)
          self.class.transaction {
            super
            self.save!
          }
        end

        def release
          self.class.transaction {
            super
            self.save!
          }
        end

        # default impl with some error handling and result recording
        def execute
          result = nil
          execution = JobExecution.create(job: self, status: STATE_EXECUTING, start_at: Time.now)

          begin
            result = self.execute_job(data)
            execution.result = result
            execution.status = 'complete'
          rescue Object => ex
            execution.result = "#{ex.class.name}: #{ex.message}\n\t#{ex.backtrace.join("\n\t")}"
            execution.status = 'error'
          end

          execution.end_at = Time.now
          execution.save!
          result
        end
      end

      module Acts #:nodoc:

        extend ActiveSupport::Concern

        module ClassMethods
          def acts_as_scheduled
            include SayWhen::Storage::ActiveRecordStrategy::Acts::InstanceMethods

            has_many :scheduled_jobs, as: :scheduled, class_name: 'SayWhen::Storage::ActiveRecordStrategy::Job', dependent: :destroy
          end
        end

        module InstanceMethods

          def schedule(job)
            Scheduler.schedule(set_scheduled(job))
          end

          def schedule_instance(next_at_method = 'next_fire_at', job = {})
            Scheduler.schedule_instance(next_at_method, set_scheduled(job))
          end

          def schedule_cron(expression, job = {})
            Scheduler.schedule_cron(expression, set_scheduled(job))
          end

          def schedule_once(time, job = {})
            Scheduler.schedule_once(time, set_scheduled(job))
          end

          def schedule_in(after, job = {})
            Scheduler.schedule_in(after, set_scheduled(job))
          end

          def set_scheduled(job)
            if job.is_a?(Hash)
              job[:scheduled] = self
            elsif job.respond_to?(:scheduled)
              job.scheduled = self
            end
            job
          end

        end # InstanceMethods
      end # class << self

    end
  end
end

aas = SayWhen::Storage::ActiveRecordStrategy::Acts
unless ActiveRecord::Base.include?(aas)
  ActiveRecord::Base.send(:include, aas)
end
