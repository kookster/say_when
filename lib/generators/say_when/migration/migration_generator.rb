# encoding: utf-8

require 'rails/generators'
require 'rails/generators/migration'
require 'rails/generators/active_record'

module SayWhen
  class MigrationGenerator < ActiveRecord::Generators::Base

    include Rails::Generators::Migration
    extend ActiveRecord::Generators::Migration

    source_root File.expand_path('../templates', __FILE__)

    argument :name, type: :string, default: 'random_name'

    def manifest
      migration_template 'migration.rb', 'db/migrate/create_say_when_tables.rb'
    end
  end
end
