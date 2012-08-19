# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "version"

Gem::Specification.new do |s|
  s.name        = "jason-orm"
  s.version     = Jason::VERSION
  s.authors     = ["Daniel Schmidt"]
  s.email       = ["dsci@code79.net"]
  s.homepage    = ""
  s.summary     = %q{JSON persistence framework}
  s.description = %q{A persistence framework based on json files.}

  
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:

  s.add_dependency "activesupport"
  s.add_dependency "require_relative"
  
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "fuubar"
  s.add_development_dependency "chronic"
end