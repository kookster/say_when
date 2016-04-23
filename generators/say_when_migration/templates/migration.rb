class SayWhenMigration < ActiveRecord::Migration
  def self.up

    create_table :say_when_jobs, :force => true do |t|

      t.string    :group
      t.string    :name

      t.string    :status

      t.string    :trigger_strategy
      t.text      :trigger_options

      t.timestamp :last_fire_at
      t.timestamp :next_fire_at

      t.timestamp :start_at
      t.timestamp :end_at

      t.string    :job_class
      t.string    :job_method
      t.text      :data

      t.string    :scheduled_type
      t.integer   :scheduled_id

      t.timestamps
    end

    create_table :say_when_job_executions, :force => true do |t|
      t.integer  :job_id
      t.string   :status
      t.text     :result
      t.datetime :start_at
      t.datetime :end_at
    end
    
    add_index :say_when_jobs, :status
    add_index :say_when_jobs, :next_fire_at
    add_index :say_when_job_executions, :job_id
  end

  
  def self.down
    drop_table :say_when_job_executions
    drop_table :say_when_jobs
  end
end