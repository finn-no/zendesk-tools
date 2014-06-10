# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'zendesk-tools/version'

Gem::Specification.new do |gem|
  gem.name          = "zendesk-tools"
  gem.version       = ZendeskTools::VERSION
  gem.authors       = ["Jari Bakken", "Eivind Throndsen"]
  gem.email         = ["jari@finn.no", "eivind.throndsen@finn.no"]
  gem.description   = %q{Tools for FINNs ZenDesk}
  gem.summary       = %q{Tools for FINNs ZenDesk}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "zendesk_api", "~> 0.1.9"
  gem.add_dependency "json"
  gem.add_dependency "rake"
  gem.add_dependency "geminabox"
  gem.add_dependency "log4r"
end
