# encoding: utf-8

module SayWhen
  module Processor

    class Simple < SayWhen::Processor::Base
      def initialize(scheduler)
        super(scheduler)
      end

      def process(job)
        job.execute
      end
    end

  end
end