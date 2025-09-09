# frozen_string_literal: true

# setting ENV["CI"] configures simplecov for continuous integration output
# setting ENV["COVERAGE"] generates a report when running tests locally
if ENV["COVERAGE"] || ENV["CI"]
  require "simplecov"
  if ENV["CI"]
    SimpleCov.formatter = SimpleCov::Formatter::SimpleFormatter
    SimpleCov.at_exit do
      puts SimpleCov.result.format!
    end
  end
  SimpleCov.start do
    # without this the simple formatter won't do anything
    add_group "lib", "lib"
  end
end
