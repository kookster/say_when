require 'minitest_helper'
require 'say_when/storage/memory/job'

describe SayWhen::Storage::Memory::Job do

  let(:valid_attributes) {
    {
      :name       => 'Memory::Job::Test',
      :group      => 'Test',
      :data       => {:foo=>'bar', :result=>1},
      :job_class  => 'SayWhen::Test::TestTask',
      :job_method => 'execute'
    }
  }

  it 'can be instantiated' do
    j = SayWhen::Storage::Memory::Job.new(valid_attributes)
    j.wont_be_nil
  end

  it 'can execute the task for the job' do
    j = SayWhen::Storage::Memory::Job.new(valid_attributes)
    j.execute_job({:result=>1}).must_equal 1
  end

  it 'can execute the job' do
    j = SayWhen::Storage::Memory::Job.new(valid_attributes)
    j.execute.must_equal 1
  end
end
