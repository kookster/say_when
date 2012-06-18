module SayWhen
  module Triggers
    module Base

      def next_fire_at(time=nil)
        raise NotImplementedError.new('You need to implement next_fire_at in your strategy')
      end

    end
  end
end