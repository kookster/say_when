module SayWhen
  module Store
    
    class Memory < SayWhen::Store::Base
      attr_accessor :store
      attr_accessor :sorted_trigger_store
  
      def initialize(mutex=Mutex.new)
        super(mutex)
        self.store = Hash.new
        self.sorted_trigger_store = SortedSet.new
      end

      def add_trigger(trigger)
        @mutex.synchronize {
          self.sorted_trigger_store.add(trigger)
          add_to_store('Trigger', trigger)
        }
      end

      def add_job(job)
        @mutex.synchronize {
          add_to_store('Job', job)
        }
      end

      def get(class_name, group, name)
        self.store[class_name][group][name] rescue nil
      end

      def get_job_for_trigger(trigger)
        get('Job', trigger.job_group, trigger.job_name)
      end
  
      def acquire_next_trigger(no_later_than)
        @mutex.synchronize {
      
          # get next trigger in order by next_fire_at
          next_trigger = self.sorted_trigger_store.first
      
          # make sure it's before or equal to no_later_than
          if next_trigger.next_fire_at.to_i <= no_later_than.to_i
            self.sorted_trigger_store.delete(next_trigger)
            return next_trigger
          else
            return nil
          end
        }
      end
  
      def release_trigger(trigger)
        self.add(trigger)
      end
  
      def trigger_fired(trigger)
        trigger.fired
        self.add(trigger)
      end

      protected

      def add_to_store(class_name, item)
        self.store[class_name] = {} if !self.store.has_key?(class_name)
        self.store[class_name][item.group] = {} if !self.store[class_name].has_key?(item.group)
        self.store[class_name][item.group][item.name] = item
      end
  

    end
  end
end