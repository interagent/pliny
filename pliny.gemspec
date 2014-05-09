$:.unshift File.expand_path("../lib", __FILE__)
require "pliny/version"

Gem::Specification.new do |gem|
  gem.name    = "pliny"
  gem.version = Pliny::VERSION

  gem.authors     = ["Brandur Leach", "Pedro Belo"]
  gem.email       = ["brandur@mutelight.org", "pedrobelo@gmail.com"]
  gem.homepage    = "https://github.com/heroku/pliny"
  gem.summary     = "Basic tooling to support API apps in Sinatra"
  gem.description = "Pliny is a set of base classes and helpers to help developers write excellent APIs in Sinatra"
  gem.license     = "MIT"

  gem.executables = %x{ git ls-files }.split("\n").select { |d| d =~ /^bin\// }.map { |d| d.gsub(/^bin\//, "") }
  gem.files = %x{ git ls-files }.split("\n").select { |d| d =~ %r{^(License|README|bin/|data/|ext/|lib/|spec/|test/)} }

  gem.add_dependency "activesupport",  "~> 4.1",  ">= 4.1.0"
  gem.add_dependency "multi_json",     "~> 1.9",  ">= 1.9.3"
  gem.add_dependency "pg",             "~> 0.17", ">= 0.17.1"
  gem.add_dependency "prmd",           "~> 0.1",  ">= 0.1.1"
  gem.add_dependency "sequel",         "~> 4.9",  ">= 4.9.0"
  gem.add_dependency "sinatra",        "~> 1.4",  ">= 1.4.5"
  gem.add_dependency "http_accept",    "~> 0.1",  ">= 0.1.5"
  gem.add_dependency "sinatra-router", "~> 0.2",  ">= 0.2.3"

  gem.add_development_dependency "rake", "~> 0.8", ">= 0.8.7"
end
