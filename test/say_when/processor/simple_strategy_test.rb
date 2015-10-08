# encoding: utf-8

require 'minitest_helper'
require 'say_when/processor/simple_strategy'

describe SayWhen::Processor::SimpleStrategy do

  let(:processor) { SayWhen::Processor::SimpleStrategy }

  it 'process a job by sending a message' do
    job = Minitest::Mock.new
    job.expect(:execute, 'done!')
    processor.process(job).must_equal 'done!'
  end
end
