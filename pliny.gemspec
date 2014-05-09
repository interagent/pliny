Gem::Specification.new do |gem|
  gem.name    = "pliny"
  gem.version = "0.0.1"

  gem.authors     = ["Brandur Leach", "Pedro Belo"]
  gem.email       = ["brandur@mutelight.org", "pedrobelo@gmail.com"]
  gem.homepage    = "https://github.com/heroku/pliny"
  gem.summary     = "Basic tooling to support API apps in Sinatra"
  gem.description = "Pliny is a set of base classes and helpers to help developers write excellent APIs in Sinatra"
  gem.license     = "MIT"

  gem.executables = %x{ git ls-files }.split("\n").select { |d| d =~ /^bin\// }.map { |d| d.gsub(/^bin\//, "") }
  gem.files = %x{ git ls-files }.split("\n").select { |d| d =~ %r{^(License|README|bin/|data/|ext/|lib/|spec/|test/)} }

  gem.add_dependency "activesupport"
  gem.add_dependency "multi_json"
  gem.add_dependency "pg"
  gem.add_dependency "prmd"
  gem.add_dependency "sequel"
  gem.add_dependency "sinatra"
  gem.add_dependency "http_accept"
  gem.add_dependency "sinatra-router"
end
