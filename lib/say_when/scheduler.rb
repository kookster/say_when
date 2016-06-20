# encoding: utf-8

require 'say_when/utils'

module SayWhen
  class Scheduler
    include SayWhen::Utils

    attr_accessor :storage

    # When passing in a job, can be a Hash, String, or Class
    # Hash: { class: '<class name>' } or { job_class: '<class name>' }
    # String: '<class name>'
    # Class: <job class>
    def schedule(job)
      storage.create(job)
    end

    def schedule_cron(expression, job)
      time_zone = if job.is_a?(Hash)
        job.delete(:time_zone)
      end || 'UTC'
      options = job_options(job)
      options[:trigger_strategy] = :cron
      options[:trigger_options]  = { expression: expression, time_zone: time_zone }
      schedule(options)
    end

    def schedule_instance(next_at_method = 'next_fire_at', job = {})
      options = job_options(job)
      options[:trigger_strategy] = 'instance'
      options[:trigger_options]  = { next_at_method: next_at_method }
      schedule(options)
    end

    def schedule_once(time, job = {})
      options = job_options(job)
      options[:trigger_strategy] = 'once'
      options[:trigger_options]  = { at: time}
      schedule(options)
    end

    def schedule_in(after, job = {})
      options = job_options(job)
      options[:trigger_strategy] = 'once'
      options[:trigger_options]  = { at: (Time.now + after)}
      schedule(options)
    end

    def job_options(job)
      {
        scheduled: extract_scheduled(job),
        job_class: extract_job_class(job),
        job_method: extract_job_method(job),
        data: extract_data(job)
      }
    end

    def extract_scheduled(job)
      job[:scheduled] if job.is_a?(Hash)
    end

    def extract_job_class(job)
      job_class = if job.is_a?(Hash)
        job[:class] || job[:job_class]
      elsif job.is_a?(Class)
        job.name
      elsif job.is_a?(String)
        job
      end

      if !job_class
        raise "Could not identify job class from: #{job}"
      end

      job_class
    end

    def extract_job_method(job)
      if job.is_a?(Hash)
        job[:method] || job[:job_method]
      end || 'execute'
    end

    def extract_data(job)
      job[:data] if job && job.is_a?(Hash)
    end

    def storage
      @storage ||= load_strategy(:storage, SayWhen.options[:storage_strategy])
    end

    def logger
      SayWhen.logger
    end
  end
end
