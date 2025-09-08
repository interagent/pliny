# frozen_string_literal: true

$:.unshift File.expand_path("../lib", __FILE__)
require "pliny/version"

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)
task default: :spec

desc "Cut a new version specified in VERSION and push"
task :release do
  unless ENV["VERSION"]
    abort("ERROR: Missing VERSION. Currently at #{Pliny::VERSION}")
  end

  current_version = Gem::Version.new(Pliny::VERSION)
  new_version = Gem::Version.new(ENV["VERSION"])

  if current_version >= new_version
    abort("ERROR: Invalid version, already at #{Pliny::VERSION}")
  end

  # update lib/pliny/version.rb
  sh "ruby",
    "-i",
    "-pe",
    "$_.gsub!(/VERSION = .*/, %{VERSION = \"#{new_version}\"})",
    "lib/pliny/version.rb"

  # update version in the template app Gemfile
  sh "ruby",
    "-i",
    "-pe",
    "$_.gsub!(/gem \"pliny\", .*/, %{gem \"pliny\", \"#{new_version.approximate_recommendation}\"})",
    "lib/template/Gemfile"

  # tag/commit
  sh "bundle install"
  sh "git commit -a -m 'v#{new_version}'"
  sh "git tag v#{new_version}"

  # build new gem and push
  sh "gem build pliny.gemspec"
  sh "gem push pliny-#{new_version}.gem"
  sh "git push origin main --tags"
  sh "rm pliny-#{new_version}.gem"
end

desc 'Open a irb/pry session preloaded with pliny'
task :console do
  require 'pry'
  require 'pliny'
  Pry.start
end
