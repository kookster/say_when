# encoding: utf-8

module SayWhen
  module Processor
    class SimpleStrategy
      class << self
        def process(job)
          job.execute
        end
      end
    end
  end
end
