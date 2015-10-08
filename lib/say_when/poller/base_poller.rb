# encoding: utf-8

require 'say_when/utils'
require 'celluloid'

module SayWhen
  module Poller
    module BasePoller

      def self.included(mod)
        mod.include(SayWhen::Utils)
      end

      def process(time_now, job)
        # delegate processing the trigger to the processor
        processor.process(job)
        logger.debug "SayWhen:: job processed: #{job.inspect}"

        # this should update next fire at, and put back in list of scheduled jobs
        storage.fired(time_now)
        logger.debug "SayWhen:: job fired: #{job.inspect}"
      end

      def acquire(time_now)
        logger.debug "SayWhen:: Looking for job that should be ready to fire before #{time_now}"
        if job = storage.acquire_next(time_now)
          logger.debug "SayWhen:: got a job: #{job.inspect}"
        else
          logger.debug "SayWhen:: no jobs to acquire"
        end
        job
      end

      def release(job)
        logger.info "SayWhen::Scheduler release: #{job.inspect}"
        job.release if job
      rescue
        logger "Failed to release job: #{job.inspect}" rescue nil
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
