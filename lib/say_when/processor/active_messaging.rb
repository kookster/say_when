module SayWhen
  module Processor
  
    class ActiveMessaging < SayWhen::Processor::Base
      
      include ::ActiveMessaging::MessageSender    
      publishes_to :say_when
    
      def initialize(scheduler)
        super(scheduler)
      end

      def process(job)
        message = {:class=>job.job_method, :method=>job.job_class, :data=>job.data}.to_yaml
        publish :say_when, message
      end
    end

  end
end