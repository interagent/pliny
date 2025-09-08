# frozen_string_literal: true

# make sure this is set before Sinatra is required
ENV["RACK_ENV"] = "test"

# have this database is available for tests
ENV["TEST_DATABASE_URL"] ||= "postgres://localhost/pliny-gem-test"

require "bundler"
Bundler.require

require "active_support/all"
require "fileutils"
require "rack/test"
require "sequel"
require "sinatra/namespace"
require "sinatra/router"
require "timecop"

require_relative "../lib/pliny"
Pliny::Utils.require_glob("./spec/support/**/*.rb")
DB = Sequel.connect(ENV["TEST_DATABASE_URL"])

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.expect_with :minitest
  config.mock_with :rspec
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.before :each do
    Pliny::RequestStore.clear!
  end

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  # the rack app to be tested with rack-test:
  def app
    @rack_app || fail("Missing @rack_app")
  end
end

Pliny.stdout = StringIO.new
Pliny.stderr = StringIO.new
