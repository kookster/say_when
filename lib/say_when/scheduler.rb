# encoding: utf-8

module SayWhen
  class Scheduler

    DEFAULT_PROCESSOR_CLASS  = SayWhen::Processor::Simple
    DEFAULT_STORAGE_STRATEGY = :memory

    @@scheduler = nil
    @@lock = nil

    attr_accessor :storage_strategy, :processor_class, :tick_length

    attr_accessor :running

    # support for a singleton scheduler, but you are not restricted to this
    class << self

      def scheduler
        self.lock.synchronize {
          if @@scheduler.nil?
            @@scheduler = self.new
          end
        }
        @@scheduler
      end

      def configure
        yield self.scheduler
        self.scheduler
      end

      def lock
        @@lock ||= Mutex.new
      end

      def schedule(job)
        self.scheduler.schedule(job)
      end

      def start
        self.scheduler.start
      end

    end

    def initialize
      self.tick_length = 1
    end

    def processor
      if @processor.nil?
        @processor_class ||= DEFAULT_PROCESSOR_CLASS
        @processor = @processor_class.new(self)
      end
      @processor
    end

    def start
      logger.info "SayWhen::Scheduler starting"

      [$stdout, $stderr].each{|s| s.sync = true; s.flush}

      trap("TERM", "EXIT")

      begin

        self.running = true

        logger.info "SayWhen::Scheduler running"
        job = nil
        while running
          begin
            time_now = Time.now
            logger.debug "SayWhen:: Looking for job that should be ready to fire before #{time_now}"
            job = job_class.acquire_next(time_now)
            if job.nil?
              logger.debug "SayWhen:: no jobs to acquire, sleep"
              sleep(tick_length)
            else
              logger.debug "SayWhen:: got a job: #{job.inspect}"
              # delegate processing the trigger to the processor
              self.processor.process(job)
              logger.debug "SayWhen:: job processed"

              # this should update next fire at, and put back in list of scheduled jobs
              job.fired(time_now)
              logger.debug "SayWhen:: job fired complete"
            end
          rescue StandardError => ex
            job_msg = job && "job: #{job.inspect} "
            logger.error "SayWhen:: Failure: #{job_msg}exception: #{ex.message}\n\t#{ex.backtrace.join("\t\n")}"
            safe_release(job)
            sleep(tick_length)
          rescue Interrupt => ex
            job_msg = job && "\n - interrupted job: #{job.inspect}\n"
            logger.error "\nSayWhen:: Interrupt! #{ex.inspect}#{job_msg}"
            safe_release(job)
            exit
          rescue Exception => ex
            job_msg = job && "job: #{job.inspect} "
            logger.error "SayWhen:: Exception: #{job_msg}exception: #{ex.message}\n\t#{ex.backtrace.join("\t\n")}"
            safe_release(job)
            exit
          end
        end
      end

      logger.info "SayWhen::Scheduler stopped"
    end

    def safe_release(job)
      job.release if job
    rescue
      logger "Failed to release job: #{job.inspect}" rescue nil
    end

    def stop
      logger.info "SayWhen::Scheduler stopping..."
      self.running = false
    end

    def job_class
      @job_class ||= load_job_class
    end

    def load_job_class
      strategy = @storage_strategy || DEFAULT_STORAGE_STRATEGY
      require "say_when/storage/#{strategy}/job"
      job_class_name = "SayWhen::Storage::#{strategy.to_s.camelize}::Job"
      job_class_name.constantize
    end

    def schedule(job)
      job_class.create(job)
    end

    def logger
      SayWhen::logger
    end
  end
end
