# require 'minitest_helper'
# require 'say_when/storage/memory/trigger'

# describe SayWhen::Storage::Memory::Trigger do

#   let(:valid_attributes) {
#     {
#       expression: '0 0 12 ? * * *',
#       time_zone: 'Pacific Time (US & Canada)'
#     }
#   }

#   it 'can be instantiated' do
#     t = SayWhen::Storage::Memory::Trigger.new(@valid_attributes)
#     t.wont_be_nil
#   end

#   it 'sets a cron_expression' do
#     t = SayWhen::Storage::Memory::Trigger.new(@valid_attributes)
#     t.cron_expression.wont_be_nil
#     t.cron_expression.expression.must_equal '0 0 12 ? * * *'
#     t.cron_expression.time_zone.must_equal 'Pacific Time (US & Canada)'
#   end

#   it 'has a waiting state on instantiate' do
#     t = SayWhen::Storage::Memory::Trigger.new(@valid_attributes)
#     t.status.must_equal SayWhen::BaseTrigger::STATE_WAITING
#   end

#   it 'has a next fire at set on instantiate' do
#     ce = SayWhen::CronExpression.new(@valid_attributes[:expression], @valid_attributes[:time_zone])
#     t = SayWhen::Storage::Memory::Trigger.new(@valid_attributes)
#     t.status.must_equal SayWhen::BaseTrigger::STATE_WAITING
#     t.next_fire_at.must_equal ce.next_fire_at
#   end

#   it 'can be fired' do
#     ce = SayWhen::CronExpression.new(@valid_attributes[:expression], @valid_attributes[:time_zone])
#     t = SayWhen::Storage::Memory::Trigger.new(@valid_attributes)
#     nfa = ce.last_fire_at(1.second.ago)
#     lfa = ce.last_fire_at(nfa - 1.second)
#     t.next_fire_at = nfa
#     t.last_fire_at = lfa

#     now = Time.now
#     Time.stub!(:now).and_return(now)

#     t.fired
#     t.next_fire_at.must_equal ce.next_fire_at(now)
#     t.last_fire_at.must_equal now
#     t.status.must_equal SayWhen::BaseTrigger::STATE_WAITING
#   end

# end