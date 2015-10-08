# encoding: utf-8

require 'minitest_helper'
require 'say_when/storage/memory_strategy'

describe SayWhen::Storage::MemoryStrategy do

  let(:valid_attributes) {
    {
      :name       => 'Memory::Job::Test',
      :group      => 'Test',
      :data       => { foo: 'bar', result: 1 },
      :job_class  => 'SayWhen::Test::TestTask',
      :job_method => 'execute'
    }
  }

  let(:strategy) { SayWhen::Storage::MemoryStrategy }

  let(:job) { strategy.create(valid_attributes) }

  it 'job can be created' do
    j = strategy.create(valid_attributes)
    j.wont_be_nil
  end

  it 'can execute the task for the job' do
    job.execute_job( { result: 1 } ).must_equal 1
  end

  it 'can execute the job' do
    j = strategy.create(valid_attributes)
    j.execute.must_equal 1
  end

  it 'can serialize' do
    j = strategy.create(valid_attributes)
    j.to_hash[:job_class].must_equal 'SayWhen::Test::TestTask'
  end
end
