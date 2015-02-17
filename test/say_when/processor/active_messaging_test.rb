# encoding: utf-8

require 'minitest_helper'

require 'say_when/processor/active_messaging'
require 'say_when/storage/active_record/job'
require 'activemessaging'

ActiveMessaging.logger = Logger.new('/dev/null')
ActiveMessaging.load_extensions

def destination(destination_name)
  d = ActiveMessaging::Gateway.find_destination(destination_name).value
  ActiveMessaging::Gateway.connection('default').find_destination d
end

describe SayWhen::Processor::ActiveMessaging do

  before do

    ActiveMessaging::Gateway.connections['default'] = ActiveMessaging::Gateway.adapters[:test].new({})

    ActiveMessaging::Gateway.define do |s|
      s.destination :say_when, '/queue/SayWhen'
    end

    SayWhen::Scheduler.configure do |scheduler|
      scheduler.storage_strategy = :active_record
      scheduler.processor_class  = SayWhen::Processor::ActiveMessaging
    end
    @processor = SayWhen::Processor::ActiveMessaging.new(SayWhen::Scheduler.scheduler)
  end

  it 'process a job by sending a message' do
    @job = Minitest::Mock.new
    @job.expect(:id, 100)
    @processor.process(@job)
    destination(:say_when).messages.size.must_equal 1
    YAML::load(destination(:say_when).messages.first.body)[:job_id].must_equal 100
  end
end
