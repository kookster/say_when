ENV["RAILS_ENV"] = "test"

require 'rubygems'
require 'test/unit'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'say_when'

class Test::Unit::TestCase
end
