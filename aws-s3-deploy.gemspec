# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'deploy/version'

Gem::Specification.new do |spec|
  spec.name          = "aws-s3-deploy"
  spec.version       = Aws::S3::Deploy::VERSION
  spec.authors       = ["Bill Centinaro"]
  spec.email         = ["bill@theresnobox.net"]
  spec.description   = %q{Deploy static files to AWS S3.}
  spec.summary       = %q{Deploys static assets to AWS S3.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_dependency 'aws-sdk-core', '2.0.0.rc9'
  spec.add_dependency "closure-compiler", "1.1.10"
end
