# frozen_string_literal: true

require "spec_helper"

RSpec.describe Endpoints::Health do
  include Rack::Test::Methods

  def app
    Endpoints::Health
  end

  describe "GET /health" do
    it "returns a 200" do
      get "/health"
      assert_equal(200, last_response.status)
      assert_equal("application/json;charset=utf-8", last_response.headers["Content-Type"])
      assert_equal(2, last_response.headers["Content-Length"].to_i)
      assert_equal({}, JSON.parse(last_response.body))
    end
  end

  describe "GET /health/db" do
    it "raises a 404 when no database is available" do
      allow(DB).to receive(:nil?).and_return(true)

      assert_raises Pliny::Errors::NotFound do
        get "/health/db"
      end
    end

    it "raises a 503 on Sequel exceptions" do
      allow(DB).to receive(:test_connection).and_raise(Sequel::Error)

      assert_raises Pliny::Errors::ServiceUnavailable do
        get "/health/db"
      end
    end

    it "raises a 503 when connection testing fails" do
      allow(DB).to receive(:test_connection).and_return(false)

      assert_raises Pliny::Errors::ServiceUnavailable do
        get "/health/db"
      end
    end

    it "returns a 200" do
      allow(DB).to receive(:test_connection).and_return(true)

      get "/health/db"
      assert_equal(200, last_response.status)
      assert_equal("application/json;charset=utf-8", last_response.headers["Content-Type"])
      assert_equal(2, last_response.headers["Content-Length"].to_i)
      assert_equal({}, JSON.parse(last_response.body))
    end
  end
end
