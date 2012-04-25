ENV['RAILS_ENV']='test'

require "rubygems"
require 'bundler/setup'
require 'active_support'

require 'spec'
require 'spec/autorun'

$: << (File.dirname(__FILE__) + "/../lib")
require "say_when"

Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

Spec::Runner.configure do |config|
  config.mock_with :rspec
end
