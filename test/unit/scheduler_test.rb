require File.dirname(__FILE__) + '/../test_helper'


module SayWhen

  class TestTask
  
    def execute(data)
      puts "say_when/test_task received: #{data.inspect}"
    end
  
  end
end

module SayWhen
  class SchedulerTest < Test::Unit::TestCase
    
    def test_define_trigger
      Time.zone = 'Central Time (US & Canada)'
      # schedule it baby!
      trigger, job = schedule(:name=>'test_define_trigger', :group=>'test', :cron_expression=>'0/10 * * * * ? *', :job_class=>'SayWhen::TestTask', :test_data_1=>1, :test_data_2=>'two')
    
      assert_equal 'test', trigger.group
      assert_equal 'test_define_trigger', trigger.name
      assert_equal 1, trigger.data[:test_data_1]
      assert_equal 'two', trigger.data[:test_data_2]
    end
    
    def test_schedule_with_time_zone
      assert_equal 'Central Time (US & Canada)', Time.zone.name
    
      # schedule it baby!
      trigger, job = schedule(:name=>'test_define_with_time_zone', :group=>'test', :cron_expression=>'0/10 * * * * ? *', :time_zone=>'Eastern Time (US & Canada)', :job_class=>'SayWhen::TestTask', :test_data_1=>1, :test_data_2=>'two')
      
      assert_equal 'Eastern Time (US & Canada)', trigger.cron_expression.time_zone
      
    end    
    
    def test_schedule_and_run_job_class
      SayWhen::TestTask.class_eval do
        def execute(data)
          # puts "make sure the data got passed to the task" 
          assert_equal 1, data[:test_data_1]
          assert_equal 'two', data[:test_data_2]
        end
      end
    
      # schedule it baby!
      trigger, job = schedule(:name=>'test_define_with_time_zone', :group=>'test', :cron_expression=>'0/10 * * * * ? *', :job_class=>'SayWhen::TestTask', :test_data_1=>1, :test_data_2=>'two')
      
      # test the job execution
      job.execute(trigger)
    end

    def test_schedule_and_run_job_block
      # schedule it baby!
      trigger, job = schedule(:name=>'test_schedule_and_run_job_block', :group=>'test', :cron_expression=>'0/10 * * * * ? *', :test_data_1=>1) do
        # puts "****\n****\n****\nexecuting job task block test_data_1=#{test_data_1}\n****\n****\n****"
        assert_equal 1, test_data_1
      end 

      # test the job execution
      job.execute(trigger)
    end

    
    # def test_schedule_duplicates
    # 
    #   # # schedule it baby!
    #   # schedule(:name=>'test_define_with_time_zone', :group=>'test', :cron_expression=>'0/10 * * * * ? *', :time_zone=>'Eastern Time (US & Canada)', :job_class=>'SayWhen::TestTask', :test_data_1=>1, :test_data_2=>'two')
    #   # 
    # end
    # 
    # # I just use this for manual testing to try stuff out :)
    # # def test_schedule_trigger_and_job
    # # 
    # #   Scheduler.define do |scheduler|
    # #     scheduler.store_class_name = 'SayWhen::ActiveRecordSchedulerStore'
    # #     scheduler.processor_class_name = 'SayWhen::SimpleProcessor'
    # #   end
    # # 
    # #   schedule(:cron_expression=>'0/10 * * * * ?', :name=>"test2", :foo=>'bar') do
    # #     puts "11111111111111111111111111111111111111111111"
    # #   end
    # # 
    # #   Scheduler.scheduler.start
    # # end
  end
end
