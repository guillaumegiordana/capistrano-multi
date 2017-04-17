# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano/multi/version'

Gem::Specification.new do |spec|
  spec.name          = "capistrano-multi"
  spec.version       = Capistrano::Multi::VERSION
  spec.authors       = ["Guillaume GIORDANA"]
  spec.email         = ["guillaume.giordana@the-oz.com"]

  spec.summary       = %q{Add multiple project folder to a capistrano project.}
  spec.description   = %q{}
  spec.homepage      = "https://github.com/guillaumegiordana/capistrano-multi"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
end
