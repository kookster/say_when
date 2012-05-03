module SayWhen

  class Scheduler

    DEFAULT_PROCESSOR_CLASS  = SayWhen::Processor::Simple
    DEFAULT_STORAGE_STRATEGY = :memory
    @@scheduler = nil
    @@lock = nil
    
    attr_accessor :storage_strategy, :processor_class

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
      @running = true
      start_scheduler_thread
      start_processor_thread
      logger.info "SayWhen::Scheduler started"
      while @running
        sleep(1)
      end
    end

    def stop
      logger.info "SayWhen::Scheduler stopping..."
      @running = false
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
      @scheduler_thread = Thread.start do
        while @running
          next_job = nil
          begin
            while (next_job.nil? && @running) do
              time_now = Time.now
              # logger.debug "Looking for job that should be ready to fire before #{time_now}"
              next_job = job_class.acquire_next(time_now)
              if next_job.nil?
                # logger.debug "no jobs to acquire, sleep"
                sleep(10)
              else
                # logger.debug "\nadding to process queue: #{next_job.inspect}\n"
                @jobs_to_process.enq(next_job)
              end
            end
          rescue Object=>ex
            logger.error "Failure when getting next trigger to process: #{ex.message}\n\t#{ex.backtrace.join("\t\n")}"
            next_job.release if next_job
          end

        end
        logger.info "SayWhen::Scheduler scheduler thread stopped"
      end
    end
    
    def start_processor_thread
      @processor_thread = Thread.start do
        while @running
          begin
            # nothing to do? sleep...
            sleep(1) if @jobs_to_process.empty?

            # dequeue the next trigger to process
            next_job = @jobs_to_process.deq

            # delegate processing the trigger to the processor
            self.processor.process(next_job)
          rescue Object=>ex
            logger.error "Failure when executing job: #{ex.message}\n\t#{ex.backtrace.join("\n\t")}"
          ensure
            next_job.fired rescue nil
          end

        end
        logger.info "SayWhen::Scheduler processor thread stopped"
      end
    end

    def logger
      SayWhen::logger
    end

  end
end
