# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "say_when/version"

Gem::Specification.new do |s|
  s.name        = "say_when"
  s.version     = SayWhen::VERSION
  s.authors     = ["Andrew Kuklewicz"]
  s.email       = ["andrew@prx.org"]
  s.homepage    = "http://labs.prx.org"
  s.summary     = %q{TODO: Write a gem summary}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "activesupport", '~> 2.3.14'
  s.add_development_dependency "activerecord", '~> 2.3.14'
  s.add_development_dependency 'rspec', "~> 1.3"
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rake'

end
