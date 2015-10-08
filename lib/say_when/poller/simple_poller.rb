# encoding: utf-8

require 'say_when/utils'

module SayWhen
  module Poller
    class SimplePoller
      include SayWhen::Utils

      attr_accessor :running, :processor, :storage

      def running?
        !!@running
      end

      def start
        begin
          @running = true

          logger.info "SayWhen::Scheduler starting"

          job = nil
          while running
            # use the same exact time for logging and recording
            time_now = Time.now
            begin
              if job = acquire(time_now)
                process(time_now, job)
              else
                tick
              end
            rescue Exception => ex
              job_msg = job && "job: #{job.inspect} "
              logger.error "SayWhen:: Failure: #{job_msg}exception: #{ex.message}\n\t#{ex.backtrace.join("\t\n")}"
              release(job)
              if ex.is_a?(Interrupt)
                raise ex
              else
                tick
              end
            end
          end
        end

        logger.info "SayWhen::Scheduler stopped"
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

      def stop
        logger.info "SayWhen::Scheduler stopping..."
        self.running = false
      end

      def tick
        sleep(SayWhen.options[:tick_length])
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
