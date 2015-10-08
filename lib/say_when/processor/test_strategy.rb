# encoding: utf-8

module SayWhen
  module Processor
    class TestStrategy
      class << self
        @jobs = []

        def process(job)
          @jobs << job
        end

        def reset
          @jobs = []
        end

        def jobs
          @jobs
        end
      end
    end
  end
end
