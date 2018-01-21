require 'active_record'
require 'say_when/storage/base_job'

module SayWhen
  module Storage
    class ActiveRecordStrategy
      class << self
        def acquire_next(no_later_than = nil)
          SayWhen::Storage::ActiveRecordStrategy::Job.acquire_next(no_later_than)
        end

        def reset_acquired(older_than_seconds)
          SayWhen::Storage::ActiveRecordStrategy::Job.reset_acquired(older_than_seconds)
        end

        def create(job)
          SayWhen::Storage::ActiveRecordStrategy::Job.job_create(job)
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
        self.table_name = "#{SayWhen.options[:table_prefix]}say_when_job_executions"
        belongs_to :job, class_name: 'SayWhen::Storage::ActiveRecordStrategy::Job'
      end

      class Job < ActiveRecord::Base
        include SayWhen::Storage::BaseJob

        self.table_name = "#{SayWhen.options[:table_prefix]}say_when_jobs"

        serialize :trigger_options
        serialize :data

        belongs_to :scheduled, polymorphic: true
        has_many  :job_executions, class_name: 'SayWhen::Storage::ActiveRecordStrategy::JobExecution'

        before_create :set_defaults

        def self.job_create(job)
          if existing_job = find_named_job(job[:group], job[:name])
            existing_job.tap { |j| j.update_attributes(job) }
          else
            create(job)
          end
        end

        def self.find_named_job(group, name)
          group && name && where(name: name, group: group).first
        end

        def self.acquire_next(no_later_than = nil)
          next_job = nil
          no_later_than = (no_later_than || Time.now).in_time_zone('UTC')

          check_connection
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

        def self.reset_acquired(older_than_seconds)
          return unless older_than_seconds.to_i > 0
          older_than = (Time.now - older_than_seconds.to_i)
          where('status = ? and updated_at < ?', STATE_ACQUIRED, older_than).update_all("status = '#{STATE_WAITING}'")
        end

        def self.check_connection
          if ActiveRecord::Base.respond_to?(:clear_active_connections!)
            ActiveRecord::Base.clear_active_connections!
          elsif ActiveRecord::Base.respond_to?(:verify_active_connections!)
            ActiveRecord::Base.verify_active_connections!
          end
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
          if SayWhen.options[:store_executions]
            result = execute_with_stored_result
          else
            begin
              result = self.execute_job(data)
              SayWhen.logger.info("complete: #{result}")
            rescue Object => ex
              result = "#{ex.class.name}: #{ex.message}\n\t#{ex.backtrace.join("\n\t")}"
              SayWhen.logger.error("error: #{result}")
            end
          end
          result
        end

        def execute_with_stored_result
          execution = JobExecution.create(job: self, status: STATE_EXECUTING, start_at: Time.now)

          begin
            execution.result = self.execute_job(data)
            execution.status = 'complete'
          rescue Object => ex
            execution.result = "#{ex.class.name}: #{ex.message}\n\t#{ex.backtrace.join("\n\t")}"
            execution.status = 'error'
          end

          execution.end_at = Time.now
          execution.save!

          execution.result
        end
      end

      module Acts #:nodoc:
        extend ActiveSupport::Concern

        module ClassMethods
          def acts_as_scheduled
            include SayWhen::Storage::ActiveRecordStrategy::Acts::InstanceMethods

            has_many :scheduled_jobs,
              as: :scheduled,
              class_name: 'SayWhen::Storage::ActiveRecordStrategy::Job',
              dependent: :destroy
          end
        end

        module InstanceMethods
          def schedule(job)
            SayWhen.schedule(set_scheduled(job))
          end

          def schedule_instance(next_at_method = 'next_fire_at', job = {})
            SayWhen.schedule_instance(next_at_method, set_scheduled(job))
          end

          def schedule_cron(expression, job = {})
            SayWhen.schedule_cron(expression, set_scheduled(job))
          end

          def schedule_once(time, job = {})
            SayWhen.schedule_once(time, set_scheduled(job))
          end

          def schedule_in(after, job = {})
            SayWhen.schedule_in(after, set_scheduled(job))
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
