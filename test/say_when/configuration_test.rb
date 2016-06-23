# encoding: utf-8

require 'minitest_helper'

describe SayWhen::Configuration do
  it 'has default values' do
    dos = SayWhen::Configuration.default_options
    dos.wont_be_nil
    dos[:processor_strategy].must_equal :simple
    dos[:storage_strategy].must_equal :memory
    dos[:tick_length].must_equal 5
    dos[:queue].must_equal "default"
  end
end
