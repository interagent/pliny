require "spec_helper"

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
    @app
  end

  it "intercepts Pliny errors and renders" do
    @app = new_rack_app
    get "/api-error"
    assert_equal 503, last_response.status
    error_json = JSON.parse(last_response.body)
    assert_equal "service_unavailable", error_json["id"]
    assert_equal "Service unavailable.", error_json["message"]
  end

  it "intercepts exceptions and renders" do
    @app = new_rack_app
    expect(Pliny::ErrorReporters).to receive(:notify)
    get "/"
    assert_equal 500, last_response.status
    error_json = JSON.parse(last_response.body)
    assert_equal "internal_server_error", error_json["id"]
    assert_equal "Internal server error.", error_json["message"]
  end

  it "raises given the raise option" do
    @app = new_rack_app(raise: true)
    assert_raises(RuntimeError) do
      get "/"
    end
  end

  it "uses a custom error message with the message option" do
    @app = new_rack_app(message: "Please stand by")
    allow(Pliny::ErrorReporters).to receive(:notify)
    get "/"
    assert_equal 500, last_response.status
    error_json = JSON.parse(last_response.body)
    assert_equal "internal_server_error", error_json["id"]
    assert_equal "Please stand by", error_json["message"]
  end

  private

  def new_rack_app(options = {})
    Rack::Builder.new do
      use Rack::Lint
      use Pliny::Middleware::RescueErrors, raise: options[:raise], message: options[:message]
      run BadMiddleware.new
    end
  end
end
