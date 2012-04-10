module SayWhen
  module Processor

    class Simple < SayWhen::Processor::Base
      def initialize(scheduler)
        super(scheduler)
      end

      def process(trigger)
        store = SayWhen::Scheduler.scheduler.store

        # get the job and execute
        job = store.get_job_for_trigger(trigger)
        job.data[:trigger] = trigger
        job.data[:fired_at] = trigger.next_fire_at
        job.execute(trigger)
      end
    end

  end
end