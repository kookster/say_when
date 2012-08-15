module SayWhen #:nodoc:
  module Storage #:nodoc:
    module ActiveRecord #:nodoc:
      module Acts #:nodoc:

        def self.included(base) # :nodoc:
          base.extend ClassMethods
        end

        module ClassMethods
          def acts_as_scheduled
            include SayWhen::Storage::ActiveRecord::Acts::InstanceMethods
          
            has_many :scheduled_jobs, :as=>:scheduled, :class_name=>'SayWhen::Storage::ActiveRecord::Job'
          end
        end
    
        module InstanceMethods

          def schedule_instance(next_at_method, job={})
            options = job_options(job)
            options[:trigger_strategy] = :instance
            options[:trigger_options]  = {:next_at_method => next_at_method}
            Scheduler.schedule(options)
          end

          def schedule_cron(expression, time_zone, job={})
            options = job_options(job)
            options[:trigger_strategy] = :cron
            options[:trigger_options]  = {:expression => expression, :time_zone => time_zone}
            Scheduler.schedule(options)
          end

          def schedule_once(time, job={})
            options = job_options(job)
            options[:trigger_strategy] = :once
            options[:trigger_options]  = {:at => time}
            Scheduler.schedule(options)
          end

          def schedule_in(after, job={})
            options = job_options(job)
            options[:trigger_strategy] = :once
            options[:trigger_options]  = {:at => (Time.now + after)}
            Scheduler.schedule(options)
          end

          # helpers

          def job_options(job)
            { :scheduled        => self,
              :job_class        => extract_job_class(job),
              :job_method       => extract_job_method(job),
              :data             => extract_data(job) }
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

ActiveRecord::Base.send(:include, SayWhen::Storage::ActiveRecord::Acts) unless ActiveRecord::Base.include?(SayWhen::Storage::ActiveRecord::Acts)
