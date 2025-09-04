$:.unshift File.expand_path("../lib", __FILE__)
require "pliny/version"

Gem::Specification.new do |gem|
  gem.name    = "pliny"
  gem.version = Pliny::VERSION

  gem.authors     = ["Brandur Leach", "Pedro Belo"]
  gem.email       = ["brandur@mutelight.org", "pedrobelo@gmail.com"]
  gem.homepage    = "https://github.com/interagent/pliny"
  gem.summary     = "Basic tooling to support API apps in Sinatra"
  gem.description = "Pliny is a set of base classes and helpers to help developers write excellent APIs in Sinatra"
  gem.license     = "MIT"

  gem.executables = %x{ git ls-files }.split("\n").select { |d| d =~ /^bin\// }.map { |d| d.gsub(/^bin\//, "") }
  gem.files = %x{ git ls-files }.split("\n").select { |d| d =~ %r{^(License|README|bin/|data/|ext/|lib/|spec/|test/)} }

  gem.required_ruby_version = ">= 3.2"

  gem.add_dependency "activesupport", ">= 7.0", "< 9.0"
  gem.add_dependency "http_accept", "~> 0.1", ">= 0.1.5"
  gem.add_dependency "ostruct"
  gem.add_dependency "prmd", "~> 0.11", ">= 0.11.4"
  gem.add_dependency "sinatra", ">= 3.0", "< 5.0"
  gem.add_dependency "sinatra-router", "~> 0.2", ">= 0.2.4"
  gem.add_dependency "thor", ">= 0.19", "< 2.0"

  gem.add_development_dependency "pg"
  gem.add_development_dependency "pry"
  gem.add_development_dependency "pry-byebug"
  gem.add_development_dependency "rack-test"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "rollbar"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "rubocop"
  gem.add_development_dependency "sequel"
  gem.add_development_dependency "sinatra-contrib"
  gem.add_development_dependency "timecop"
end
