module SayWhen
  module Processor
  
    # some limitations - won't work with in memory store, a13g processor code needs to be specfic to scheduler store class
    class ActiveMessaging < SayWhen::Processor::Base
      
      include ::ActiveMessaging::MessageSender
    
      publishes_to :say_when_a13g_process_trigger
    
      def initialize(scheduler)
        super(scheduler)
      end

      def process(trigger)
        message = [trigger.name, trigger.group, trigger.next_fire_at].to_yaml
        # puts "before send message to say_when_a13g_process_trigger: #{message}"
        publish :say_when_a13g_process_trigger, message
      end
    end

  end
end