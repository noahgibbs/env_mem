# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'env_mem/version'

Gem::Specification.new do |spec|
  spec.name          = "env_mem"
  spec.version       = EnvMem::VERSION
  spec.authors       = ["Noah Gibbs"]
  spec.email         = ["the.codefolio.guy@gmail.com"]

  spec.summary       = %q{EnvMem takes a GC.stat dump and produce a memory-optimized script for your large Ruby app.}
  spec.description   = %q{EnvMem allows you to dump your GC.stat information from a long-running server, then produce a simple shellscript to set up your Ruby memory environment variables to match that configuration. This improves startup time slightly and allows you finer-grain control over your memory setup. If you've ever found Ruby memory environment variables on a web page and used them to try to speed up your app, this is a better approach.}
  spec.homepage      = "https://github.com/noahgibbs/env_mem"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
