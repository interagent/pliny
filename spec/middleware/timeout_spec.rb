require "spec_helper"

describe Pliny::Middleware::Timeout do
  include Rack::Test::Methods

  def app
    Rack::Builder.new do
      use Rack::Lint
      use Pliny::Middleware::Timeout
      run Sinatra.new {
        get "/" do
          200
        end

        get "/timeout" do
          raise Pliny::Middleware::Timeout::RequestTimeout
        end
      }
    end
  end

  it "passes through requests that don't timeout normally" do
    get "/"
    assert_equal 200, last_response.status
  end

  it "responds with an error on a timeout" do
    assert_raises(Pliny::Errors::ServiceUnavailable) do
      get "/timeout"
    end
  end
end
