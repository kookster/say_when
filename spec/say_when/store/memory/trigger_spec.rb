require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/../../../../lib/say_when/store/memory/trigger'

describe SayWhen::Store::Memory::Trigger do

  before(:each) do
    @valid_attributes = {
      :expression => '0 0 12 ? * * *',
      :time_zone  => 'Pacific Time (US & Canada)'
    }
  end

  it "can be created using new and save" do
    t = SayWhen::Store::Memory::Trigger.new(@valid_attributes)
    t.should_not be_nil
  end

  it "sets a cron_expression" do
    t = SayWhen::Store::Memory::Trigger.new(@valid_attributes)
    t.cron_expression.should_not be_nil
    t.cron_expression.expression.should == '0 0 12 ? * * *'
    t.cron_expression.time_zone.should == 'Pacific Time (US & Canada)'
  end

  it "has a waiting state on create" do
    t = SayWhen::Store::Memory::Trigger.new(@valid_attributes)
    t.status.should == SayWhen::BaseTrigger::STATE_WAITING
  end

  it "has a next fire at set on create" do
    ce = SayWhen::CronExpression.new(@valid_attributes[:expression], @valid_attributes[:time_zone])
    t = SayWhen::Store::Memory::Trigger.new(@valid_attributes)
    t.status.should == SayWhen::BaseTrigger::STATE_WAITING
    t.next_fire_at.should == ce.next_fire_at
  end

  it "can be fired" do
    ce = SayWhen::CronExpression.new(@valid_attributes[:expression], @valid_attributes[:time_zone])
    t = SayWhen::Store::Memory::Trigger.new(@valid_attributes)
    nfa = ce.last_fire_at(1.second.ago)
    lfa = ce.last_fire_at(nfa - 1.second)
    t.next_fire_at = nfa
    t.last_fire_at = lfa

    now = Time.now
    Time.stub!(:now).and_return(now)

    t.fired
    t.next_fire_at.should == ce.next_fire_at(now)
    t.last_fire_at.should == now
    t.status.should == SayWhen::BaseTrigger::STATE_WAITING
  end

end