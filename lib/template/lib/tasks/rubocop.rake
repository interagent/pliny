# frozen_string_literal: true

if Gem.loaded_specs.has_key?("rubocop-rspec")
  require "rubocop/rake_task"

  RuboCop::RakeTask.new do |task|
    task.requires << "rubocop-rspec"
  end
end
