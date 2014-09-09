$:.unshift File.expand_path("../lib", __FILE__)
require "pliny/version"
require "rake/testtask"

task default: :test

Rake::TestTask.new do |task|
  task.libs << "lib"
  task.libs << "test"
  task.name = :test
  task.test_files = FileList["test/**/*_test.rb"]
end

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

  sh "ruby", "-i", "-pe", "$_.gsub!(/VERSION = .*/, %{VERSION = \"#{new_version}\"})", "lib/pliny/version.rb"
  sh "bundle install"
  sh "git commit -a -m 'v#{new_version}'"
  sh "git tag v#{new_version}"
  sh "gem build pliny.gemspec"
  # sh "gem push pliny-#{new_version}.gem"
  sh "git push origin master --tags"
  sh "rm pliny-#{new_version}.gem"
end
