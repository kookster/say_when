# encoding: utf-8

module SayWhen
  module Utils

    def load_strategy(type, strategy)
      if strategy.is_a?(Symbol) || strategy.is_a?(String)
        require "say_when/#{type}/#{strategy}_strategy"
        class_name = "SayWhen::#{type.to_s.camelize}::#{strategy.to_s.camelize}Strategy"
        class_name.constantize
      else
        strategy
      end
    end
  end
end
