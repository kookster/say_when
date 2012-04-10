module SayWhen

  class Processor
    
    attr_accessor :scheduler
    
    def initialize(scheduler)
      @scheduler = scheduler
    end
    
    def process(trigger)   
      raise 'you gonna have to implement this buddy'
    end
    
  end

end