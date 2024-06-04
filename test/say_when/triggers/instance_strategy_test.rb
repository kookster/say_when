# encoding: utf-8

require 'minitest_helper'
require 'say_when/triggers/instance_strategy'

describe SayWhen::Triggers::InstanceStrategy do
  it 'should be constucted with next_at_method option' do
    job = Minitest::Mock.new
    job.expect(:scheduled, true)
    t = SayWhen::Triggers::InstanceStrategy.new(next_at_method: 'test_next_at_method', job: job)
    expect(t).wont_be_nil
  end
end
