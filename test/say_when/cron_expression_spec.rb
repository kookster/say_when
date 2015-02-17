# encoding: utf-8

require File.dirname(__FILE__) + '/../spec_helper'

describe SayWhen::CronExpression do

  it 'should set the time_zone' do
    @ce = SayWhen::CronExpression.new("0 0 12 ? * 1#1 *", 'Pacific Time (US & Canada)')
    @ce.time_zone.must_equal 'Pacific Time (US & Canada)'
  end

  describe 'get first sunday in the month with "1#1' do

    before do
      @ce = SayWhen::CronExpression.new("0 0 12 ? * 1#1 *", 'Pacific Time (US & Canada)')
    end

    it 'finds first sunday in the same month' do
      @ce.next_fire_at(Time.utc(2008,1,1)).must_equal Time.parse('2008-01-06 12:00:00 -0800')
    end


    it 'finds first sunday in the next month' do
      @ce.next_fire_at(Time.utc(2008,1,7)).must_equal Time.parse('2008-02-03 12:00:00 -0800')
    end

    it 'finds last sunday in the same month' do
      @ce.last_fire_at(Time.utc(2008,1,10)).must_equal Time.parse('2008-01-06 12:00:00 -0800')
    end

    it 'finds sundays in the prior months and years' do
      @ce.last_fire_at(Time.utc(2008,1,5)).must_equal Time.parse('2007-12-02 12:00:00 -0800')
      @ce.last_fire_at(Time.parse('2007-12-02 12:00:00 -0800') - 1.second).must_equal Time.parse('2007-11-04 12:00:00 -0800')
      @ce.last_fire_at(Time.parse('2007-11-04 12:00:00 -0800') - 1.second).must_equal Time.parse('2007-10-07 12:00:00 -0700')
      @ce.next_fire_at(Time.parse('2007-10-07 12:00:00 -0700') + 1.second).must_equal Time.parse('2007-11-04 12:00:00 -0800')
    end
  end

  describe 'get last sunday in the month with "1L"' do
    before do
      @ce = SayWhen::CronExpression.new("0 0 12 ? * 1L *", 'Pacific Time (US & Canada)')
    end

    it 'gets next final sunday for same month' do
      @ce.next_fire_at(Time.utc(2008,1,1)).must_equal Time.parse('2008-01-27 12:00:00 -0800')
    end


    it 'gets next final sunday for next month' do
      @ce.next_fire_at(Time.utc(2008,1,28)).must_equal Time.parse('2008-02-24 12:00:00 -0800')
    end

    it 'gets last final sunday for same month' do
      @ce.last_fire_at(Time.utc(2008,1,28)).must_equal Time.parse('2008-01-27 12:00:00 -0800')
    end

    it 'gets last sunday for prior month and year' do
      @ce.last_fire_at(Time.utc(2008,1,1)).must_equal Time.parse('2007-12-30 12:00:00 -0800')
    end


    it 'gets last sunday for prior month and year' do
      nfa = @ce.last_fire_at(Time.utc(2007,12,1))
      nfa.must_equal Time.parse('2007-11-25 12:00:00 -0800')

      nfa = @ce.last_fire_at(nfa - 1.second)
      nfa.must_equal Time.parse('2007-10-28 12:00:00 -0700')

      nfa = @ce.next_fire_at(nfa + 1.second)
      nfa.must_equal Time.parse('2007-11-25 12:00:00 -0800')
    end

  end
end
