# # encoding: utf-8
#
# require 'minitest_helper'
# require 'activemessaging'
#
# def destination(destination_name)
#   d = ActiveMessaging::Gateway.find_destination(destination_name).value
#   ActiveMessaging::Gateway.connection('default').find_destination d
# end
#
# describe 'ActiveMessagingStrategy' do
#
#   before do
#     ActiveMessaging.logger = Logger.new('/dev/null')
#     ActiveMessaging.load_extensions
#     ActiveMessaging::Gateway.connections['default'] = ActiveMessaging::Gateway.adapters[:test].new({})
#     ActiveMessaging::Gateway.destination :say_when, "TestSayWhen"
#     require 'say_when/processor/active_messaging_strategy'
#   end
#
#   let(:processor) { SayWhen::Processor::ActiveMessagingStrategy }
#
#   it 'process a job by sending a message' do
#     @job = Minitest::Mock.new
#     @job.expect(:id, 100)
#
#     processor.process(@job)
#     destination(:say_when).messages.size.must_equal 1
#     YAML::load(destination(:say_when).messages.first.body)['job_id'].must_equal 100
#   end
# end
