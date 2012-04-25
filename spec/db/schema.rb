ActiveRecord::Schema.define(:version => 0) do

  create_table :say_when_job_executions, :force => true do |t|
    t.integer  :job_id
    t.integer  :trigger_id
    t.string   :status
    t.text     :result
    t.datetime :start_at
    t.datetime :end_at
  end

  create_table :say_when_triggers, :force => true do |t|
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

  create_table :say_when_jobs, :force => true do |t|
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