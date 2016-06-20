# encoding: utf-8
require 'minitest_helper'

require 'active_support/all'
require 'say_when/cron_expression'

describe SayWhen::CronExpression do

  it 'should create with defaults' do
    ce = SayWhen::CronExpression.new
    ce.expression.must_equal "* * * ? * ? *"
    ce.time_zone.must_equal Time.zone.try(:name) || "UTC"
  end

  it 'should set the time_zone' do
    ce = SayWhen::CronExpression.new("0 0 12 ? * 1#1 *", 'Pacific Time (US & Canada)')
    ce.time_zone.must_equal 'Pacific Time (US & Canada)'
  end

  it 'has a pretty to_s' do
    ce = SayWhen::CronExpression.new("1 1 1 1 1 ? 2000")
    ce.to_s.must_match /s:.*/
  end

  it 'handles #/# numbers' do
    ce = SayWhen::CronExpression.new("*/10 1 1 1 1 ? 2000")
    ce.seconds.values.must_equal [0, 10, 20, 30, 40, 50]
  end

  it 'handles #,# numbers' do
    ce = SayWhen::CronExpression.new("1,2 1 1 1 1 ? 2000")
    ce.seconds.values.must_equal [1, 2]
  end

  it 'handles #-# numbers' do
    ce = SayWhen::CronExpression.new("1-3 1 1 1 1 ? 2000")
    ce.seconds.values.must_equal [1, 2, 3]
  end

  it 'no values when no match' do
    ce = SayWhen::CronExpression.new("na 1 1 1 1 ? 2000")
    ce.seconds.values.must_equal []
  end

  it 'handles changes in seconds' do
    ce = SayWhen::CronExpression.new("1-3 1 1 1 1 ? 2000", "UTC")
    n = ce.next_fire_at(Time.utc(1999,1,1))
    n.must_equal Time.parse("Sat, 01 Jan 2000 01:01:01 UTC")

    n = ce.next_fire_at(Time.parse("Sat, 01 Jan 2000 01:00:59 UTC"))
    n.must_equal Time.parse("Sat, 01 Jan 2000 01:01:01 UTC")
  end

  describe "Day of the month" do
    it "gets the last day of the month" do
      ce = SayWhen::CronExpression.new("0 0 0 L 1 ? 2004", 'UTC')
      ce.next_fire_at(Time.utc(1999,1,1)).must_equal Time.parse('Sat, 31 Jan 2004 00:00:00 UTC +00:00')
    end

    it "gets the last weekday of the month" do
      ce = SayWhen::CronExpression.new("0 0 0 LW 1 ? 2004", 'UTC')
      ce.next_fire_at(Time.utc(1999,1,1)).must_equal Time.parse('Fri, 30 Jan 2004 00:00:00 UTC +00:00')
    end

    it "gets a weekday in the month" do
      ce = SayWhen::CronExpression.new("0 0 0 W 1 ? 2000", 'UTC')
      ce.next_fire_at(Time.utc(1999,1,1)).must_equal Time.parse('Mon, 03 Jan 2000 00:00:00 UTC +00:00')
    end

    it "gets the closest weekday in the month" do
      ce = SayWhen::CronExpression.new("0 0 0 1W 1 ? 2000", 'UTC')
      ce.next_fire_at(Time.utc(1999,1,1)).must_equal Time.parse('Tue, 03 Jan 2000 00:00:00 UTC +00:00')

      ce = SayWhen::CronExpression.new("0 0 0 10W 1 ? 2000", 'UTC')
      ce.next_fire_at(Time.utc(1999,1,1)).must_equal Time.parse('Mon, 10 Jan 2000 00:00:00 UTC +00:00')
    end
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
