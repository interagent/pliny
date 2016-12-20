
require "rubocop/rake_task"

RuboCop::RakeTask.new do |task|
  task.requires << "rubocop-rspec"
end
