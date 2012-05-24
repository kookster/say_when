module SayWhen
  module Storage
    module Memory

      module Base
        
        attr_accessor :props

        def has_properties(*args)
          @props ||= []
          args.each do |a|
            unless @props.member?(a.to_s)
              @props << a.to_s
              class_eval { attr_accessor(a.to_sym) }
            end
          end
        end

        def self.included(base)
          base.extend self
        end

        def initialize(args={})
          args.each do |k,v|
            if self.class.props.member?(k.to_s)
              self.send("#{k}=", v)
            end
          end
        end
      end

    end
  end
end
