# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'representable/cache/version'

Gem::Specification.new do |spec|
  spec.name          = "representable-cache"
  spec.version       = Representable::Cache::VERSION
  spec.authors       = ["Allen Wei"]
  spec.email         = ["digruby@gmail.com"]
  spec.description   = %q{cache solution for representable}
  spec.summary       = %q{cache solution for representable}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "representable"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "dalli"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "debugger"
end
