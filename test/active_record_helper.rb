# encoding: utf-8

require 'active_record'
require 'sqlite3'

ActiveRecord::Base.logger = Logger.new('/dev/null')

ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: (File.dirname(__FILE__) + '/db/test.db')
)

require (File.dirname(__FILE__) + '/db/schema.rb')
