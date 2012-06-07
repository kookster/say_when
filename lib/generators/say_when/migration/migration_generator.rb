require 'rails/generators'
require 'rails/generators/migration'
require 'rails/generators/active_record/migration'

module SayWhen
  class MigrationGenerator < Rails::Generators::Base

    include Rails::Generators::Migration
    extend ActiveRecord::Generators::Migration

    source_root File.expand_path('../templates', __FILE__)

    def manifest 
      migration_template 'migration.rb', 'db/migrate/create_say_when_tables' 
    end
    
  end
end
