# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cocoslicer/version'

Gem::Specification.new do |gem|
  gem.name          = "cocoslicer"
  gem.version       = Cocoslicer::VERSION
  gem.authors       = ["jtianling"]
  gem.email         = ["jtianling@gmail.com"]
  gem.description   = %q{Slicer the packed cocos2d resources(with tool TexturePacker) into the original ones. Don't support zwoptex now.}
  gem.summary       = %q{Slicer the packed cocos2d resources into the original ones.}
  gem.homepage      = "http://www.jtianling.com"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = ["cocoslicer"]
  gem.require_paths = ["lib"]
  gem.required_ruby_version = '>= 1.8.6'
  gem.requirements << 'libmagick, v6.0'
  gem.requirements << 'plist'
end
