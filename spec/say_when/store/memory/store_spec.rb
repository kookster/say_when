require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/../../../../lib/say_when/store/memory/store'

describe SayWhen::Store::Memory::Store do

  before(:each) do
    @valid_attributes = {
    }
  end

  it "can be instantiated" do
    j = SayWhen::Store::Memory::Store.new(@valid_attributes)
    j.should_not be_nil
  end

end
