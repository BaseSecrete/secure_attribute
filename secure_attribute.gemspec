# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'secure_attribute/version'

Gem::Specification.new do |spec|
  spec.name          = "secure_attribute"
  spec.version       = SecureAttribute::VERSION
  spec.authors       = ["Alexis Bernard"]
  spec.email         = ["alexis@bernard.io"]
  spec.summary       = "Encrypt attributes of any Ruby object or ActiveRecord model."
  spec.description   = "Encrypt attributes of any Ruby object or ActiveRecord model."
  spec.homepage      = "https://github.com/BaseSecrete/secure_attribute"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z lib`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
end
