# encoding: utf-8

require 'minitest_helper'
require 'active_job'
require 'say_when/processor/active_job_strategy'

describe SayWhen::Processor::ActiveJobStrategy do

  let(:processor) { SayWhen::Processor::ActiveJobStrategy }

  before {
    SayWhen::Test::TestTask.executed = false
  }

  it 'process a memory stored job' do
    options = {
      name:  'Test',
      group: 'Test',
      data:  { foo: 'bar', result: 1 },
      job_class: 'SayWhen::Test::TestTask',
      job_method: 'execute'
    }

    SayWhen::Test::TestTask.wont_be :executed

    job = SayWhen::Storage::MemoryStrategy.create(options)
    processor.process(job)

    SayWhen::Test::TestTask.must_be :executed
  end
end
