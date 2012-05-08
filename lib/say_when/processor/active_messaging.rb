module SayWhen
  module Processor
  
    class ActiveMessaging < SayWhen::Processor::Base
      
      include ::ActiveMessaging::MessageSender    
    
      def initialize(scheduler)
        super(scheduler)
      end

      # send the job to the other end, then in the a13g processor, call the execute method
      def process(job)
        message = {:job_id=>job.id}.to_yaml
        publish :say_when, message
      end
    end

  end
end