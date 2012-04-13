module Kernel

  TRIGGER_OPTIONS = [:name, :group, :job, :scheduled, :expression, :cron_expression, :time_zone]
  JOB_OPTIONS = [:name, :group, :task_class, :task_method]
  ALL_OPTIONS = [:name, :group, :job, :scheduled, :expression, :cron_expression, :time_zone, :task_class, :task_method]

  # one big hash of args, pull what we need to create trigger and job hashes
  def schedule(*args, &block)
    job = nil
    trigger = nil

    if args.first.is_a?(Hash)
      
      options = args.first
      
      if options.include?(:trigger)
        if options[:trigger].is_a?(SayWhen::Trigger)
          trigger = options[:trigger]
        elsif options[:trigger].is_a?(Hash)
          trigger_hash = options[:trigger]
        end
      else
        # puts "1 inspect options: #{options.inspect}"
        # only get trigger options
        trigger_hash = options.reject{|k,v| !TRIGGER_OPTIONS.include?(k)}
        # puts "2 inspect options: #{options.inspect}"
      end

      if options.include?(:job)
        if options[:job].is_a?(SayWhen::Job)
          job = options[:job]
        elsif options[:job].is_a?(Hash)
          job_hash = options[:job]
        end
      else
        # puts "3 inspect options: #{options.inspect}"
        # only get job options
        job_hash = options.reject{|k,v| !JOB_OPTIONS.include?(k)}
        # puts "4 inspect options: #{options.inspect}"
      end
    end
    
    if job.nil?
      job = if trigger_hash.include?(:job) && trigger_hash[:job].is_a?(Job)
        trigger_hash[:job]
      else
        if block_given?
          job = SayWhen::ProcJob.new(job_hash)
          job.task_block = block 
          job.task_self = self.dup
          job
        else
          SayWhen::ClassJob.new(job_hash)
        end
      end
    end
    # puts "5 inspect options: #{options.inspect}"
    job.data ||= options.reject{|k,v| ALL_OPTIONS.include?(k)}
    # puts "job.data = #{job.data.inspect}"


    if trigger.nil?
      trigger = if trigger_hash.include?(:cron_expression)
        SayWhen::CronTrigger.define(trigger_hash)
      else
        raise 'Look, I only have one impl of trigger so far, you need to pass in a :cron_expression option.'
      end
    end
    # puts "6 inspect options: #{options.inspect}"
    trigger.data ||= options.reject{|k,v| ALL_OPTIONS.include?(k)}
    # puts "trigger.data = #{trigger.data.inspect}"
    
    return SayWhen::Scheduler.schedule(trigger, job)
  end
  
  def unschedule(trigger)
    return SayWhen::Scheduler.unschedule(trigger)
  end

end
