# -*- encoding: utf-8 -*-
require File.expand_path('../lib/paul_rake/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Andrew Kim"]
  gem.email         = ["andrewtevinkim@gmail.com"]
  gem.description   = %q{Paul's rake tasks in a railtie gem created by Andrew Kim}
  gem.summary       = %q{Paul's rake tasks}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "paul_rake"
  gem.require_paths = ["lib"]
  gem.version       = PaulRake::VERSION
end
