require "test_helper"

describe Pliny::Extensions::Instruments do
  def app
    Rack::Builder.new do
      run Sinatra.new {
        register Pliny::Extensions::Instruments

        get "/apps/:id" do
          status 201
          "hi"
        end
      }
    end
  end

  it "performs logging" do
    mock(Pliny).log(hash_including(
      instrumentation: true,
      at:              "start",
      method:          "GET",
      path:            "/apps/123",
    ))
    mock(Pliny).log(hash_including(
      instrumentation: true,
      at:              "finish",
      method:          "GET",
      path:            "/apps/123",
      route_signature: "/apps/:id",
      status:          201
    ))
    get "/apps/123"
  end
end
