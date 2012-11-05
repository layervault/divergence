# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'divergence/version'

Gem::Specification.new do |gem|
  gem.name          = "divergence"
  gem.version       = Divergence::VERSION
  gem.authors       = ["Ryan LeFevre"]
  gem.email         = ["ryan@layervault.com"]
  gem.description   = "Map subdomains to git branches for switching live codebases on the fly. It's a Rack application that acts as a HTTP proxy between you and your web application for rapid testing."
  gem.summary       = "Map virtual host subdomains to git branches for testing"
  gem.homepage      = "http://cosmos.layervault.com/divergence.html"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "rack"
  gem.add_dependency "rack-proxy"
  gem.add_dependency "thor"
  gem.add_dependency "json"
  gem.add_development_dependency "rack-test"
end
