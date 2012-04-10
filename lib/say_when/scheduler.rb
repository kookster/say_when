module SayWhen

  class Scheduler

    DEFAULT_STORE_CLASS_NAME = 'SayWhen::MemorySchedulerStore'
    DEFAULT_PROCESS_CLASS_NAME = 'SayWhen::SimpleProcessor'
    @@scheduler = nil
    @@mutex = Mutex.new
    
    attr_accessor :trigger_queue, :store_class_name, :processor_class_name

    # support for a singleton scheduler, but you are not restricted to this
    class << self

      def scheduler
        @@scheduler = self.new if @@scheduler.nil?
        @@scheduler
      end

      def define
        yield self.scheduler
        self.scheduler
      end

      def schedule(trigger, job)
        self.scheduler.schedule(trigger, job)
      end
      
      def unschedule(trigger)
        self.scheduler.unschedule(trigger)
      end

      def mutex
        @@mutex
      end

    end

    def logger
      SayWhen::logger
    end

    def initialize
      # default the store to a hash for now
      @store = nil
      @processor = nil
      @triggers_to_process = Queue.new
      logger.info "SayWhen::Scheduler initialized"
    end
    
    def store
      if @store.nil?
        @store_class_name ||= DEFAULT_STORE_CLASS_NAME
        @store = @store_class_name.constantize.new
      end
      @store
    end

    def processor
      if @processor.nil?
        @processor_class_name ||= DEFAULT_PROCESSOR_CLASS_NAME
        @processor = @processor_class_name.constantize.new(self)
      end
      @processor
    end

    def schedule(trigger, job)
      # TODO: validate you have both trigger and job
      
      # see if the trigger & job have a group, name
      trigger.name ||= 'default'
      trigger.group ||= 'default'
      job.name ||= trigger.name
      job.group ||= trigger.group

      j = self.store.add_job(job)
      trigger.job = j
      t = self.store.add_trigger(trigger)
      return [t,j]
    end

    def unschedule(trigger)
      self.store.remove_trigger(trigger)
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

    private

    def start_scheduler_thread
      scheduler_thread = Thread.start do
        while @running
          job = nil
          nt = nil
          begin
            while (nt.nil? && @running) do
              time_now = Time.now
              # logger.debug "Looking for job that should be ready to fire before #{time_now}"
              nt = self.store.acquire_next_trigger(time_now)
              if nt.nil?
                # logger.debug "no triggers to acquire, sleep"
                sleep(5)
              else
                # logger.debug "\nadding to process queue: #{nt.inspect}\n"
                @triggers_to_process.enq(nt)
              end
            end
          rescue Object=>ex
            logger.error "Failure when getting next trigger to process: #{ex.message}\n\t#{ex.backtrace.join("\t\n")}"
            self.store.release_trigger(nt) if nt
          end

        end
        logger.info "SayWhen::Scheduler scheduler thread stopped"
      end
    end
    
    def start_processor_thread
      processor_thread = Thread.start do
        while @running
          begin
            # nothing to do? sleep...
            sleep(1) if @triggers_to_process.empty?

            # dequeue the next trigger to process
            nt = @triggers_to_process.deq

            # delegate processing the trigger to the processor
            self.processor.process(nt)
            self.store.trigger_fired(nt)
          rescue Object=>ex
            logger.error "Failure when executing job: #{ex.message}\n\t#{ex.backtrace.join("\n\t")}"
            self.store.trigger_error(nt, ex) unless nt.nil?
          end

        end
        logger.info "SayWhen::Scheduler processor thread stopped"
      end
    end
  end
end
