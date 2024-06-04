# encoding: utf-8

require 'minitest_helper'

describe SayWhen::Configuration do
  it 'has default values' do
    dos = SayWhen::Configuration.default_options
    expect(dos).wont_be_nil
    expect(dos[:processor_strategy]).must_equal :simple
    expect(dos[:storage_strategy]).must_equal :memory
    expect(dos[:tick_length]).must_equal 5
    expect(dos[:queue]).must_equal "default"
  end
end
