require_relative '../../spec_helper'
require_relative '../../../lib/say_when/triggers/once_strategy'

describe SayWhen::Triggers::OnceStrategy do

  it "should be constucted with at option" do
    time_at = 1.second.ago
    o = SayWhen::Triggers::OnceStrategy.new({:at=>time_at})
    o.should_not be_nil
    o.once_at.should == time_at
  end

  it "should return once at only once" do
    time_at = 1.second.ago
    o = SayWhen::Triggers::OnceStrategy.new({:at=>time_at})
    o.should_not be_nil
    o.next_fire_at.should == time_at
    o.next_fire_at(time_at + 10.second).should be_nil
    o.next_fire_at(time_at - 10.second).should == time_at
  end

end