require File.dirname(__FILE__) + '/../../../test_helper'

SayWhen.store = :memory

module SayWhen
  module Store
    module Memory

      class CronExpressionTest < Test::Unit::TestCase

        def test_trigger_create
          @trigger = SayWhen::Store::Memory::Trigger.new          
        end
      end

    end
  end
end
