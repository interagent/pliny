require "spec_helper"

describe Pliny::Middleware::CORS do
  def app
    Rack::Builder.new do
      use Rack::Lint
      use Pliny::Middleware::CORS
      run Sinatra.new {
        get "/" do
          "hi"
        end
      }
    end
  end

  it "doesn't do anything when the Origin header is not present" do
    get "/"
    assert_equal 200, last_response.status
    assert_equal "hi", last_response.body
    assert_nil last_response.headers["Access-Control-Allow-Origin"]
  end

  it "intercepts OPTION requests to render a stub (preflight request)" do
    header "Origin", "http://localhost"
    options "/"
    assert_equal 200, last_response.status
    assert_equal "", last_response.body
    assert_equal "GET, POST, PUT, PATCH, DELETE, OPTIONS",
      last_response.headers["Access-Control-Allow-Methods"]
    assert_equal "http://localhost",
      last_response.headers["Access-Control-Allow-Origin"]
  end

  it "delegates other calls, adding the CORS headers to the response" do
    header "Origin", "http://localhost"
    get "/"
    assert_equal 200, last_response.status
    assert_equal "hi", last_response.body
    assert_equal "http://localhost",
      last_response.headers["Access-Control-Allow-Origin"]
  end
end
