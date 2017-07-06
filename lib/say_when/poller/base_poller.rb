# encoding: utf-8

require 'say_when/utils'

module SayWhen
  module Poller
    module BasePoller
      def self.included(mod)
        mod.include(SayWhen::Utils)
        attr_accessor :reset_next_at
      end

      def stop
      end

      def start
      end

      def reset_acquired
        time_now = Time.now
        self.reset_next_at ||= time_now

        if reset_acquired_length > 0 && reset_next_at <= time_now
          self.reset_next_at = time_now + reset_acquired_length
          logger.debug "SayWhen:: reset acquired at #{time_now}, try again at #{reset_next_at}"
          storage.reset_acquired(reset_acquired_length)
        end
      end

      def job_error(msg, job, ex)
        job_msg = job && " job:'#{job.inspect}'"
        logger.error "#{self.class.name} #{msg}#{job_msg}: #{ex.message}\n\t#{ex.backtrace.join("\t\n")}"
        release(job)
      end

      def process_jobs
        reset_acquired
        time_now = Time.now
        while job = acquire(time_now)
          process(job, time_now)
          time_now = Time.now
        end
      rescue StandardError => ex
        job_error("Error!", job, ex)
        tick(error_tick_length)
      rescue Interrupt => ex
        job_error("Interrupt!", job, ex)
        raise ex
      rescue Exception => ex
        job_error("Exception!", job, ex)
        raise ex
      end

      def acquire(time_now)
        logger.debug "SayWhen:: Looking for job that should be ready to fire before #{time_now}"
        if job = self.storage.acquire_next(time_now)
          logger.debug "SayWhen:: got a job: #{job.inspect}"
        else
          logger.debug "SayWhen:: no jobs to acquire"
        end
        job
      end

      def process(job, time_now)
        # delegate processing the trigger to the processor
        processor.process(job)
        logger.debug "SayWhen:: job processed: #{job.inspect}"

        # this should update next fire at, and put back in list of scheduled jobs
        storage.fired(job, time_now)
        logger.debug "SayWhen:: job fired: #{job.inspect}"
      end

      def release(job)
        logger.info "SayWhen::Scheduler release: #{job.inspect}"
        job.release if job
      end

      def tick(t = tick_length)
        sleep(t.to_f)
      end

      def tick_length
        @tick_length ||= SayWhen.options[:tick_length].to_f
      end

      def error_tick_length
        @error_tick_length ||= SayWhen.options[:error_tick_length].to_f || tick_length
      end

      def reset_acquired_length
        @reset_acquired_length ||= SayWhen.options[:reset_acquired_length].to_f
      end

      def processor
        @processor ||= load_strategy(:processor, SayWhen.options[:processor_strategy])
      end

      def storage
        @storage ||= load_strategy(:storage, SayWhen.options[:storage_strategy])
      end

      def logger
        SayWhen.logger
      end
    end
  end
end
