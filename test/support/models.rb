# encoding: utf-8

require 'active_support'

class TestModel < Object
  attr_accessor :id

  def initialize(id=nil)
    @id = id
  end

  def ==(b)
    return false unless b
    # puts "compare: #{self.class.name}_#{@id} == #{b.class.name}_#{b.id}"
    @id == b.id
  end

  class << self

    def find(ids=nil)
      Array(ids).collect{|i| self.new(i)}
    end

  end

end

class User < TestModel
end

class Account < TestModel
  attr_accessor :owner
end
