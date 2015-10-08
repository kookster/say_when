# # encoding: utf-8
#
# require 'activemessaging'
# require 'json'
#
# module SayWhen
#   module Processor
#     class ActiveMessagingStrategy
#       class << self
#
#         def process(job)
#           message = { job_id: job.id }.to_json
#           ActiveMessaging::Gateway.publish(:say_when, message, self)
#         end
#       end
#
#       active_messaging_super_class = if defined?(::ApplicationProcessor)
#         ::ApplicationProcessor
#       else
#         ::ActiveMessaging::Processor
#       end
#
#       class SayWhenProcessor < active_messaging_super_class
#
#         subscribes_to :say_when, { ack: 'client' }
#
#         def on_message(message)
#           message_hash = JSON.parse(message)
#           job = job_class.find_by_id(message_hash['job_id'])
#           job.execute
#         end
#
#         def job_class
#           SayWhen::Scheduler.scheduler.job_class
#         end
#       end
#     end
#   end
# end
