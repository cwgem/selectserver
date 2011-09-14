# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "cwgem-selectserver/version"

Gem::Specification.new do |s|
  s.name        = "cwgem-selectserver"
  s.version     = Cwgem::SelectServer::VERSION
  s.authors     = ["Chris White"]
  s.email       = ["cwprogram@live.com"]
  s.homepage    = ""
  s.summary     = %q{A basic TCP server that uses IO.select multiplexing}
  s.description = %q{A basic TCP server that uses IO.select multiplexing}

  s.rubyforge_project = "cwgem-selectserver"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
