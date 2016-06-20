# encoding: utf-8

module SayWhen
  module Processor
    class TestStrategy
      class << self

        def process(job)
          self.jobs << job
        end

        def reset
          self.jobs = []
        end

        def jobs
          @jobs ||= []
        end
      end
    end
  end
end
