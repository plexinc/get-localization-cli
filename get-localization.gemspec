# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'get-localization/version'

Gem::Specification.new do |gem|
  gem.name          = "get-localization"
  gem.version       = GetLocalization::VERSION
  gem.authors       = ["Schuyler Ullman"]
  gem.email         = ["schuyler@plexapp.com"]
  gem.summary       = %q{Command line tool to interact with Get Localization translations.}
  gem.description   = %q{This gem provides a simple command line tool for working with translations through Get Localization.}
  gem.homepage      = "http://github.com/sullman/get-localization"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = ["get-localization"]
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency('thor')
  gem.add_dependency('highline')
  gem.add_dependency('json')
  gem.add_dependency('multipart-post')
end
