require File.dirname(__FILE__) + '/../test_helper'

module SayWhen
  class CronExpressionTest < Test::Unit::TestCase

    def test_nth_day_of_week
      # get first sunday in the month with "1#1"
      ce = SayWhen::CronExpression.new("0 0 12 ? * 1#1 *", 'Pacific Time (US & Canada)')
      assert_not_nil ce
    
      nfa = ce.next_fire_at(Time.utc(2008,1,1))
      assert_equal '2008-01-06 12:00:00 -0800', nfa.to_s 
    
      nfa = ce.next_fire_at(Time.utc(2008,1,7))
      assert_equal '2008-02-03 12:00:00 -0800', nfa.to_s 
          
      nfa = ce.last_fire_at(Time.utc(2008,1,10))
      assert_equal '2008-01-06 12:00:00 -0800', nfa.to_s 
          
      nfa = ce.last_fire_at(Time.utc(2008,1,5))
      assert_equal '2007-12-02 12:00:00 -0800', nfa.to_s 

      nfa = ce.last_fire_at(nfa)
      assert_equal '2007-11-04 12:00:00 -0800', nfa.to_s 

      nfa = ce.last_fire_at(nfa)
      assert_equal '2007-10-07 12:00:00 -0700', nfa.to_s 

      nfa = ce.next_fire_at(nfa)
      assert_equal '2007-11-04 12:00:00 -0800', nfa.to_s 

    end
    
    def test_last_day_of_week
      # get last sunday in the month with "1L"
      ce = CronExpression.new("0 0 12 ? * 1L *", 'Pacific Time (US & Canada)')
      assert_not_nil ce
    
      nfa = ce.next_fire_at(Time.utc(2008,1,1))
      assert_equal '2008-01-27 12:00:00 -0800', nfa.to_s

      nfa = ce.next_fire_at(Time.utc(2008,1,28))
      assert_equal '2008-02-24 12:00:00 -0800', nfa.to_s
      
      nfa = ce.last_fire_at(Time.utc(2008,1,28))
      assert_equal '2008-01-27 12:00:00 -0800', nfa.to_s

      nfa = ce.last_fire_at(Time.utc(2008,1,1))
      assert_equal '2007-12-30 12:00:00 -0800', nfa.to_s

      nfa = ce.last_fire_at(Time.utc(2007,12,1))
      assert_equal '2007-11-25 12:00:00 -0800', nfa.to_s

      nfa = ce.last_fire_at(nfa)
      assert_equal '2007-10-28 12:00:00 -0700', nfa.to_s

      nfa = ce.next_fire_at(nfa)
      assert_equal '2007-11-25 12:00:00 -0800', nfa.to_s
    end
    
  end
end
