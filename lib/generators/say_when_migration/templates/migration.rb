class SayWhenMigration < ActiveRecord::Migration
  def self.up
    create_table :say_when_triggers do |t|
      t.references :job
      t.string :type
      t.string :name
      t.string :group
      t.string :data
      t.string :expression
      t.string :status
      t.boolean :is_paused
      t.boolean :is_blocked
      t.timestamp :last_fire_at
      t.timestamp :next_fire_at
      t.timestamp :start_at
      t.timestamp :end_at
      t.string :time_zone
      t.timestamps
    end

    create_table :say_when_jobs do |t|
      t.string :name
      t.string :group
      t.string :data
      t.string :job_class
      t.string :job_method
      t.timestamps
    end
    
    add_index :say_when_triggers, :name
    add_index :say_when_triggers, :group
    add_index :say_when_triggers, :status
    add_index :say_when_triggers, :next_fire_at
    add_index :say_when_jobs, :name
    add_index :say_when_jobs, :group
  end
  
  def self.down
    drop_table :say_when_triggers
    drop_table :say_when_jobs
  end

end
