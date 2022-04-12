require "bundler/gem_tasks"
require 'spec/rake/spectask'

desc "Run all tests"
Spec::Rake::SpecTask.new('test') do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
end

task :default => :test
