module SayWhen
  class MigrationGenerator < Rails::Generator::Base
    def manifest 
      record do |m| 
        m.migration_template 'migration.rb', 'db/migrate' 
      end 
    end
    
    def file_name
      "say_when_migration"
    end
  end
end