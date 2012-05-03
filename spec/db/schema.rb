ActiveRecord::Schema.define(:version => 0) do

  create_table :say_when_jobs, :force => true do |t|

    t.string    :status

    t.string    :trigger_strategy
    t.text      :trigger_options
    t.string    :time_zone

    t.timestamp :last_fire_at
    t.timestamp :next_fire_at

    t.timestamp :start_at
    t.timestamp :end_at

    t.string    :job_class
    t.string    :job_method
    t.text      :data

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


end