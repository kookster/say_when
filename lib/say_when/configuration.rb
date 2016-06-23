require 'yaml'
require 'erb'

module SayWhen
  class Configuration
    def self.default_options
      {}.tap do |defaults|
        defaults[:processor_strategy] = :simple
        defaults[:storage_strategy] = :memory
        defaults[:tick_length] = (ENV['SAY_WHEN_TICK_LENGTH'] || '5').to_i
        defaults[:queue] = ENV['SAY_WHEN_QUEUE'] || 'default'
        defaults[:reset_acquired_length] = (ENV['SAY_WHEN_RESET_ACQUIRED_LENGTH'] || '3600').to_i
      end
    end
  end
end
