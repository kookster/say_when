require 'yaml'
require 'erb'

module SayWhen
  class Configuration
    def self.default_options
      {}.tap do |defaults|
        # if defined?(::ActiveJob)
        #   defaults[:processor_strategy] = :active_job
        # else
          defaults[:processor_strategy] = :simple
        # end

        if defined?(::ActiveRecord)
          defaults[:storage_strategy] = :active_record
        else
          defaults[:storage_strategy] = :memory
        end

        defaults[:tick_length] = (ENV['SAY_WHEN_TICK_LENGTH'] || '5').to_i
        defaults[:queue] = ENV['SAY_WHEN_QUEUE'] || 'default'
      end
    end
  end
end
