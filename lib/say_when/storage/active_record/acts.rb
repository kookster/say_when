module SayWhen #:nodoc:
  module Storage #:nodoc:
    module ActiveRecord #:nodoc:
      module Acts #:nodoc:

        def self.included(base) # :nodoc:
          base.extend ClassMethods
        end

        module ClassMethods
          def acts_as_scheduled
            include SayWhen::Storage::ActiveRecord::Acts::InstanceMethods
          
            has_many :jobs, :as=>:scheduled, :class_name=>'SayWhen::Storage::ActiveRecord::Job'
          end
        end
    
        module InstanceMethods
        end # InstanceMethods
      
      end
    end
  end
end

ActiveRecord::Base.send(:include, SayWhen::Storage::ActiveRecord::Acts) unless ActiveRecord::Base.include?(SayWhen::Storage::ActiveRecord::Acts)
