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
          rescue Object=>ex
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
            include SayWhen::Storage::ActiveRecord::Acts::InstanceMethods

            has_many :scheduled_jobs, as: :scheduled, class_name: 'SayWhen::Storage::ActiveRecordStrategy::Job', dependent: :destroy
          end
        end

        module InstanceMethods

          def schedule_instance(next_at_method = 'next_fire_at', job = {})
            options = job_options(job)
            options[:trigger_strategy] = 'instance'
            options[:trigger_options]  = { next_at_method: next_at_method }
            Scheduler.schedule(options)
          end

          def schedule_cron(expression, job = {})
            time_zone = if job.is_a?(Hash)
              job.delete(:time_zone)
            end || 'UTC'
            options = job_options(job)
            options[:trigger_strategy] = 'cron'
            options[:trigger_options]  = { expression: expression, time_zone: time_zone }
            Scheduler.schedule(options)
          end

          def schedule_once(time, job = {})
            options = job_options(job)
            options[:trigger_strategy] = 'once'
            options[:trigger_options]  = { at: time}
            Scheduler.schedule(options)
          end

          def schedule_in(after, job = {})
            options = job_options(job)
            options[:trigger_strategy] = 'once'
            options[:trigger_options]  = { at: (Time.now + after)}
            Scheduler.schedule(options)
          end

          # helpers

          def job_options(job)
            {
              scheduled:  self,
              job_class:  extract_job_class(job),
              job_method: extract_job_method(job),
              data:       extract_data(job)
            }
          end

          def extract_job_class(job)
            if job.is_a?(Hash)
              job[:class]
            elsif job.is_a?(Class)
              job.name
            elsif job.is_a?(String)
              job
            else
              raise "Could not identify job class from: #{job}"
            end
          end

          def extract_job_method(job)
            if job.is_a?(Hash)
              job[:method]
            else
              'execute'
            end
          end

          def extract_data(job)
            if job.is_a?(Hash)
              job[:data]
            else
              nil
            end
          end
        end # InstanceMethods
      end

    end
  end
end

ActiveRecord::Base.send(:include, SayWhen::Storage::ActiveRecordStrategy::Acts) unless ActiveRecord::Base.include?(SayWhen::Storage::ActiveRecordStrategy::Acts)
