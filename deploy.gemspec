# -*- encoding: utf-8 -*-
require File.expand_path('../lib/deploy/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Andrew Kim","paul.verschoor@gmail.com"]
  gem.email         = ["paul.verschoor@gmail.com"]
  gem.description   = %q{deploy rake tasks in a railtie gem created by Andrew Kim}
  gem.summary       = %q{rake tasks for deployment of Thin clusters and Nginx configuration files.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "deploy"
  gem.require_paths = ["lib"]
  gem.version       = Deploy::VERSION
end
