module SayWhen
  module Processor
    
    class Base
      attr_accessor :scheduler
    
      def initialize(scheduler)
        @scheduler = scheduler
      end
    
      def process(job)
        raise NotImplementedError.new('You need to implement process(job)')
      end
    end

  end
end