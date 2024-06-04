# encoding: utf-8

require 'minitest_helper'

describe SayWhen do

  it 'provides a default logger' do
    expect(SayWhen.logger).wont_be_nil
  end

  it 'can set a new logger' do
    l = Logger.new('/dev/null')
    SayWhen.logger = l
    expect(l).must_equal l
  end

  it 'provides the scheduler' do
    expect(SayWhen.scheduler).wont_be_nil
  end
end
