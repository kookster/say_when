# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'say_when/version'

Gem::Specification.new do |spec|
  spec.name          = 'say_when'
  spec.version       = SayWhen::VERSION
  spec.authors       = ['Andrew Kuklewicz']
  spec.email         = ['andrew@beginsinwonder.com']
  spec.summary       = %q{Scheduling system for programmatically defined and stored jobs.}
  spec.description   = %q{Scheduling system for programmatically defined and stored jobs.}
  spec.homepage      = 'https://github.com/kookster/say_when'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency('activesupport')

  spec.add_development_dependency('bundler')
  spec.add_development_dependency('rake')
  spec.add_development_dependency('minitest')
  spec.add_development_dependency('guard')
  spec.add_development_dependency('guard-minitest')
  spec.add_development_dependency('simplecov')
  spec.add_development_dependency('coveralls')

  spec.add_development_dependency('sqlite3')
  spec.add_development_dependency('activerecord')
  spec.add_development_dependency('celluloid')
  spec.add_development_dependency('concurrent-ruby')
  spec.add_development_dependency('activejob')
end
