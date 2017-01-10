require "spec_helper"

describe Pliny::Middleware::CanonicalLogLine do
  def app
    Rack::Builder.new do
      run Sinatra.new {
        use Pliny::Middleware::RequestID

        use Pliny::Middleware::CanonicalLogLine,
          emitter: -> (data) { Pliny.log_without_context(data) }

        use Pliny::Middleware::RescueErrors, raise: false

        get "/apps/:id" do
          status 201
          "hi"
        end

        get "/generic-error" do
          raise ArgumentError, "argument error"
        end

        get "/pliny-error" do
          raise Pliny::Errors::NotFound
        end
      }
    end
  end

  it "emits on a successful request" do
    data = {}
    expect(Pliny).to receive(:log_without_context) { |d| data = d }

    header "User-Agent", "rack-test"
    get "/apps/123"

    assert_match Pliny::Middleware::RequestID::UUID_PATTERN,
      data[:request_id]
    assert_equal "127.0.0.1", data[:request_ip]
    assert_equal "GET", data[:request_method]
    assert_equal "/apps/123", data[:request_path]
    assert_equal "/apps/:id", data[:request_route_signature]
    assert_equal "rack-test", data[:request_user_agent]

    assert_equal 2, data[:response_length]
    assert_equal 201, data[:response_status]
  end

  it "never fails a request on failure" do
    expect(Pliny).to receive(:log).with(
      message: "Failed to emit canonical log line")
    expect(Pliny).to receive(:log_without_context) { |d| raise "bang!" }

    get "/apps/123"
    assert_equal 201, last_response.status
  end

  it "emits on generic error" do
    data = {}
    expect(Pliny).to receive(:log_without_context) { |d| data = d }
    get "/generic-error"

    assert_equal "ArgumentError", data[:error_class]
    assert_equal "argument error", data[:error_message]

    assert_equal "GET", data[:request_method]
    assert_equal "/generic-error", data[:request_path]
    assert_equal "/generic-error", data[:request_route_signature]

    assert_equal 500, data[:response_status]
  end

  it "emits on Pliny error" do
    data = {}
    expect(Pliny).to receive(:log_without_context) { |d| data = d }
    get "/pliny-error"

    assert_equal "Pliny::Errors::NotFound", data[:error_class]
    assert_equal "Not found.", data[:error_message]
    assert_equal "not_found", data[:error_id]

    assert_equal "GET", data[:request_method]
    assert_equal "/pliny-error", data[:request_path]
    assert_equal "/pliny-error", data[:request_route_signature]

    assert_equal 404, data[:response_status]
  end
end
