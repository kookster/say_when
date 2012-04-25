require 'say_when/store/memory/trigger'

class SayWhen::Trigger < SayWhen::Store::Memory::Trigger; end

module SayWhen
  module Store
    module Memory
    
      class Store

        include SayWhen::BaseStore

        attr_accessor :store
        attr_accessor :sorted_trigger_store
    
        def initialize
          self.store = Hash.new
          self.sorted_trigger_store = SortedSet.new
        end

        def add_trigger(trigger)
          self.lock.synchronize {
            self.sorted_trigger_store.add(trigger)
            add_to_store('Trigger', trigger)
          }
        end

        def add_job(job)
          self.lock.synchronize {
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
          self.lock.synchronize {
            
            next_trigger = sorted_trigger_store.detect(nil) do |t| 
              (t.status == SayWhen::BaseTrigger::STATE_WAITING) &&
              (t.next_fire_at.to_i <= no_later_than.to_i)
            end

            next_trigger.status = SayWhen::BaseTrigger::STATE_ACQUIRED if next_trigger

            next_trigger
          }
        end
    
        def release_trigger(trigger)
          self.lock.synchronize {
            trigger.status = SayWhen::Trigger::STATE_WAITING
          }
        end
    
        def trigger_fired(trigger)
          self.lock.synchronize {
            trigger.fired
            self.add_trigger(trigger)
          }
        end

        def trigger_error(trigger, exception)
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
end