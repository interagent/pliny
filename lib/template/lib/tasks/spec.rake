# define our own version of the spec task because rspec might not be available
# in the production environment, so we can't rely on RSpec::Core::RakeTask
desc "Run all app specs"
task :spec do
  require "rspec/core"
  code = RSpec::Core::Runner.run(
    ["./spec"],
    $stderr, $stdout)
  exit(code) unless code == 0
end
