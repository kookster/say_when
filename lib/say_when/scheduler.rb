module SayWhen

  class Scheduler

    DEFAULT_PROCESSOR_CLASS  = SayWhen::Processor::Simple
    DEFAULT_STORAGE_STRATEGY = :memory

    @@scheduler = nil
    @@lock = nil

    attr_accessor :storage_strategy, :processor_class, :tick_length, :reset_acquired_length

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
      self.reset_acquired_length = 3600
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
        reset_next_at = Time.now
        while running
          begin
            time_now = Time.now

            if reset_acquired_length > 0 && reset_next_at <= time_now
              reset_next_at = time_now + reset_acquired_length
              logger.debug "SayWhen:: reset acquired at #{time_now}, try again at #{reset_next_at}"
              job_class.reset_acquired(reset_acquired_length)
            end

            begin
              logger.debug "SayWhen:: Looking for job that should be ready to fire before #{time_now}"
              job = job_class.acquire_next(time_now)
            rescue StandardError => ex
              job_error("Failure to acquire job", job, ex)
              job = nil
            end

            if job.nil?
              logger.debug "SayWhen:: no jobs to acquire, sleep"
              sleep(tick_length)
              next
            end

            begin
              logger.debug "SayWhen:: got a job: #{job.inspect}"
              # delegate processing the trigger to the processor
              self.processor.process(job)
              logger.debug "SayWhen:: job processed"

              # if successful, update next fire at, put back to waiting / ended
              job.fired(time_now)
              logger.debug "SayWhen:: job fired complete"
            rescue StandardError=>ex
              job_error("Failure to process", job, ex)
            end

          rescue Interrupt => ex
            job_error("Interrupt!", job, ex)
            raise ex
          rescue StandardError => ex
            job_error("Error!", job, ex)
            sleep(tick_length)
          rescue Exception => ex
            job_error("Exception!", job, ex)
            raise ex
          end
        end
      rescue Exception=>ex
        logger.error "SayWhen::Scheduler stopping, error: #{ex.class.name}: #{ex.message}"
        exit
      end

      logger.info "SayWhen::Scheduler stopped"
    end

    def job_error(msg, job, ex)
      job_msg = job && " job:'#{job.inspect}'"
      logger.error "SayWhen::Scheduler #{msg}#{job_msg}: #{ex.message}\n\t#{ex.backtrace.join("\t\n")}"
      job.release if job
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
