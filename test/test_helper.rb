# make sure this is set before Sinatra is required
ENV["RACK_ENV"] = "test"

require "bundler"
Bundler.require(:default, :test)

require "minitest/autorun"
require "rr"

require_relative "../lib/pliny"

class MiniTest::Spec
  include Rack::Test::Methods

  before do
    Pliny::RequestStore.clear!
  end
end
