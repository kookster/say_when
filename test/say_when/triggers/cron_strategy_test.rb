# encoding: utf-8

require 'minitest_helper'
require 'say_when/triggers/cron_strategy'

describe SayWhen::Triggers::CronStrategy do
  it 'should be constucted with a cron expression' do
    t = SayWhen::Triggers::CronStrategy.new(expression: '0 0 * ? * * *', job: {})
    expect(t).wont_be_nil
  end
end
