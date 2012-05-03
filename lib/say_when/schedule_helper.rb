module SayWhen
  module ScheduleHelper

    def cron(expression, time_zone, job)
      options = {
        :trigger_strategy => :cron,
        :trigger_options  => {:expression => expression, :time_zone => time_zone},
        :job_class        => extract_job_class(job),
        :job_method       => extract_job_method(job)
      }

      Scheduler.schedule(options)
    end

    def once(time, job)
      options = {
        :trigger_strategy => :once,
        :trigger_options  => time,
        :job_class        => extract_job_class(job),
        :job_method       => extract_job_method(job)
      }

      Scheduler.schedule(options)
    end

    protected

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

  end
end
