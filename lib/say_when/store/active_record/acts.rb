module SayWhen #:nodoc:
  module Acts #:nodoc:
    module Scheduled #:nodoc:

      def self.included(base) # :nodoc:
        base.extend ClassMethods
      end

      module ClassMethods
        def acts_as_scheduled
          include SayWhen::Acts::Scheduled::InstanceMethods
          
          has_many :triggers, :as=>:scheduled, :class_name=>'SayWhen::Trigger' do
            
            def active
              find(:all, :conditions=>["status != ? && status != ?", SayWhen::Trigger::STATE_ERROR, SayWhen::Trigger::STATE_COMPLETE])
            end

          end
          
        end
      end
    
      module InstanceMethods
      end # InstanceMethods
      
    end
  end
end
