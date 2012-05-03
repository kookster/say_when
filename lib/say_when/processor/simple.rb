module SayWhen
  module Processor

    class Simple < SayWhen::Processor::Base
      def initialize(scheduler)
        super(scheduler)
      end

      def process(job)
        job.execute(trigger)
      end
    end

  end
end