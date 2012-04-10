module SayWhen

  class Store
    
    class<<self
      def config=(store_name='active_record')
        @store_name = store_name
      end
      
      def load
        require "say_when/#{store_name}/#{store_name}_store"
      end
    end
    
    def initialize(mutex=Mutex.new)
      @mutex = mutex
    end
    
    def add_trigger(item)
    end

    def add_job(item)
    end

    def get(class_name, group, name)
    end

    def get_job_for_trigger(trigger)
    end

    # could change at some point to acquire more than one at a time...
    def acquire_next_trigger(no_later_than)
    end
  
    def release_trigger(trigger)
    end
  
    def trigger_fired(trigger)
    end
  end

end