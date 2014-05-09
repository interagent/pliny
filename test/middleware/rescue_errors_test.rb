require "test_helper"

describe Pliny::Middleware::RescueErrors do
  include Rack::Test::Methods

  class BadMiddleware
    def call(env)
      if env["PATH_INFO"] == "/api-error"
        raise Pliny::Errors::ServiceUnavailable
      else
        raise "Omg!"
      end
    end
  end

  def app
    Rack::Builder.new do
      use Rack::Lint
      use Pliny::Middleware::RescueErrors
      run BadMiddleware.new
    end
  end

  it "intercepts Pliny errors and renders" do
    get "/api-error"
    assert_equal 503, last_response.status
    error_json = MultiJson.decode(last_response.body)
    assert_equal "service_unavailable", error_json["id"]
    assert_equal "Service unavailable.", error_json["message"]
    assert_equal 503, error_json["status"]
  end

  it "intercepts exceptions and renders" do
    get "/"
    assert_equal 500, last_response.status
    error_json = MultiJson.decode(last_response.body)
    assert_equal "internal_server_error", error_json["id"]
    assert_equal "Internal server error.", error_json["message"]
    assert_equal 500, error_json["status"]
  end
end
