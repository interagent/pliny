require "pliny/tasks"

# Add your rake tasks to lib/tasks!
Dir["./lib/tasks/*.rake"].each { |task| load task }

task :spec do
  require "rspec/core"
  code = RSpec::Core::Runner.run(
    ["./spec"],
    $stderr, $stdout)
  exit(code) unless code == 0
end

task :default => :spec
