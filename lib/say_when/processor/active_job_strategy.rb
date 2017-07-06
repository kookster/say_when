# encoding: utf-8

require 'active_job'

module SayWhen
  module Processor
    class ActiveJobStrategy
      class << self
        def process(job)
          SayWhenJob.perform_later(job_to_arg(job))
        end

        def job_to_arg(job)
          case job
          when GlobalID::Identification
            job
          else
            { class: job.class.name, attributes: job.to_hash }
          end
        end
      end

      class SayWhenJob < ActiveJob::Base
        queue_as SayWhen.options[:queue]

        def perform(job)
          if job.is_a?(Hash)
            job = job[:class].constantize.new(job[:attributes])
          end
          job.execute
        end
      end
    end
  end
end
