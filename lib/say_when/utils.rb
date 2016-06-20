# encoding: utf-8

module SayWhen
  module Utils

    def load_strategy(strategy_type, strategy)
      if strategy.is_a?(Symbol) || strategy.is_a?(String)
        require "say_when/#{strategy_type}/#{strategy}_strategy"
        class_name = "SayWhen::#{strategy_type.to_s.camelize}::#{strategy.to_s.camelize}Strategy"
        strategy_class = class_name.constantize
        strategy_class
      else
        strategy
      end
    end
  end
end
