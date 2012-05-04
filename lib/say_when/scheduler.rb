module SayWhen

  class Scheduler

    DEFAULT_PROCESSOR_CLASS  = SayWhen::Processor::Simple
    DEFAULT_STORAGE_STRATEGY = :memory
    @@scheduler = nil
    @@lock = nil
    
    attr_accessor :storage_strategy, :processor_class, :tick_length

    attr_accessor :running, :processor_thread, :scheduler_thread

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

    end

    def initialize
      @jobs_to_process = Queue.new
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
      logger.info "SayWhen::Scheduler starting..."
      self.running = true
      self.scheduler_thread = start_scheduler_thread
      self.processor_thread = start_processor_thread
      threads_running = scheduler_thread.alive? || processor_thread.alive?
      logger.info "SayWhen::Scheduler started"
      while (running || threads_running)
        logger.info "SayWhen::Scheduler running"
        trap("TERM", "EXIT")
        threads_running = self.scheduler_thread.alive? || self.processor_thread.alive?
        Thread.pass
        sleep(1)
      end
      logger.info "SayWhen::Scheduler stopped"
    end

    def stop
      logger.info "SayWhen::Scheduler stopping..."
      self.running = false
    end

    def job_class
      @job_class ||= load_job_class
    end

    def load_job_class
      strategy = @storage_strategy || :memory
      require "say_when/storage/#{strategy}/job"
      job_class_name = "SayWhen::Storage::#{strategy.to_s.camelize}::Job"
      job_class_name.constantize
    end

    def schedule(job)
      job_class.create(job)
    end

    private

    def start_scheduler_thread
      Thread.start do
        next_job = nil
        while running
          begin
            time_now = Time.now
            logger.debug "SayWhen:: Looking for job that should be ready to fire before #{time_now}"
            next_job = job_class.acquire_next(time_now)
            if next_job.nil?
              logger.debug "SayWhen:: no jobs to acquire, sleep"
              sleep(tick_length)
            else
              logger.debug "SayWhen:: adding to process queue: #{next_job.inspect}"
              @jobs_to_process.enq(next_job)
            end
          rescue Object=>ex
            begin
              logger.error "SayWhen:: Failure when getting next trigger to process: #{ex.message}\n\t#{ex.backtrace.join("\t\n")}"
              next_job.release if next_job
            rescue
              puts ex
            end
          end
          Thread.pass
        end
        logger.info "SayWhen::Scheduler scheduler thread stopped"
      end
    end
    
    def start_processor_thread
      Thread.start do
        next_job = nil
        while running
          logger.info "SayWhen::Scheduler processor thread running"
          begin
            # nothing to do? sleep...
            if @jobs_to_process.empty?
              sleep(1)
            else
              # dequeue the next trigger to process
              next_job = @jobs_to_process.deq

              # delegate processing the trigger to the processor
              self.processor.process(next_job)

              # this should update next fire at, and put back in list of scheduled jobs
              next_job.fired
            end
          rescue Object=>ex
            begin
              logger.error "SayWhen:: Failure when processing jobs: #{ex.message}\n\t#{ex.backtrace.join("\n\t")}"
              next_job.release if next_job
            rescue
              puts ex
            end
          end
          Thread.pass
        end
        logger.info "SayWhen::Scheduler processor thread stopped"
      end
    end

    def logger
      SayWhen::logger
    end

  end
end
