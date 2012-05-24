require 'mongoid'

Mongoid.configure do |config|
  config.master = Mongo::Connection.new.db("say_when_test")
end

# Mongoid.logger = Logger.new($stdout)
