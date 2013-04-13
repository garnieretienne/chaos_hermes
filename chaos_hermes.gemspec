# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hermes/version'

Gem::Specification.new do |gem|
  gem.name          = "chaos_hermes"
  gem.version       = Hermes::VERSION
  gem.authors       = ["Etienne Garnier"]
  gem.email         = ["garnier.etienne@gmail.com"]
  gem.description   = %q{Console utility and library to manage nginx routes}
  gem.summary       = %q{Generate and manage nginx config file for each application proxied by nginx. This tool needs 'nginx' and 'sudo' installed on the system. Part of Chaos Open PaaS.}
  gem.homepage      = "https://github.com/garnieretienne/chaos_hermes"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  
  gem.add_dependency "thor"
end
