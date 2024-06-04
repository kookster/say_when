# encoding: utf-8

require 'minitest_helper'
require 'say_when/triggers/once_strategy'

describe SayWhen::Triggers::OnceStrategy do

  it 'should be constucted with at option' do
    time_at = 1.second.ago
    o = SayWhen::Triggers::OnceStrategy.new(at: time_at, job: {})
    expect(o).wont_be_nil
    expect(o.once_at).must_equal time_at
  end

  it 'should return once at only once' do
    time_at = 1.second.ago
    o = SayWhen::Triggers::OnceStrategy.new(at: time_at, job: {})
    expect(o).wont_be_nil
    expect(o.next_fire_at).must_equal time_at
    expect(o.next_fire_at(time_at + 10.second)).must_be_nil
    expect(o.next_fire_at(time_at - 10.second)).must_equal time_at
  end
end
