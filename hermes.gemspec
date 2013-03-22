# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hermes/version'

Gem::Specification.new do |gem|
  gem.name          = "hermes"
  gem.version       = Hermes::VERSION
  gem.authors       = ["Etienne Garnier"]
  gem.email         = ["garnier.etienne@gmail.com"]
  gem.description   = %q{Console utility and libraries to manage nginx routes}
  gem.summary       = %q{Generate and manage nginx config file for each application proxied by nginx}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  
  gem.add_dependency "thor"
end
