require File.dirname(__FILE__) + '/../../../test_helper'

SayWhen.store = :active_record

module SayWhen
  module Store
    module ActiveRecord

      class TriggerTest < Test::Unit::TestCase

        def test_trigger_create
          @trigger = SayWhen::Store::ActiveRecord::Trigger.new          
        end
      end

    end
  end
end
