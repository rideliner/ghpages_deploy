# encoding: utf-8
# Copyright (c) 2016 Nathan Currier

require './lib/ghpages_deploy/version'

Gem::Specification.new do |spec|
  spec.name          = 'ghpages_deploy'
  spec.version       = GithubPages::VERSION
  spec.authors       = ['Nathan Currier']
  spec.email         = ['nathan.currier@gmail.com']
  spec.license       = 'BSD-3-Clause'

  spec.description   = 'Deploy to Github Pages'
  spec.summary       = 'Deploy your site to Github Pages'
  spec.homepage      = 'https://github.com/rideliner/ghpages_deploy'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'bundler', '>= 1.11.2'
end
