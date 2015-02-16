# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "say_when/version"

Gem::Specification.new do |s|
  s.name        = "say_when"
  s.version     = SayWhen::VERSION
  s.authors     = ["Andrew Kuklewicz"]
  s.email       = ["andrew@prx.org"]
  s.homepage    = "http://labs.prx.org"
  s.summary     = %q{Scheduling system for programmatically defined and stored jobs.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'activesupport'

  s.add_development_dependency 'activerecord'
  s.add_development_dependency 'shoryuken'
  s.add_development_dependency 'activemessaging'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rake'
end
