# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "harness/active_publisher/version"

Gem::Specification.new do |spec|
  spec.name          = "harness-active_publisher"
  spec.version       = Harness::ActivePublisher::VERSION
  spec.authors       = ["Michael Ries"]
  spec.email         = ["michael@riesd.com"]

  spec.summary       = "a gem to collect instrumation stats from active_publisher and forward them to harness"
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/mxenabled/harness-active_publisher"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "activesupport", ">= 3.2"
  spec.add_runtime_dependency "harness", ">= 2.0.0"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
