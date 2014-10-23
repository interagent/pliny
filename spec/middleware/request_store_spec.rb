require "spec_helper"

describe Pliny::Middleware::RequestStore do
  def app
    Rack::Builder.new do
      use Rack::Lint
      use Pliny::Middleware::RequestStore, store: Pliny::RequestStore
      run Sinatra.new {
        get "/" do
          "hi"
        end
      }
    end
  end

  it "clears the store" do
    mock(Pliny::RequestStore).clear!
    get "/"
  end

  it "seeds the store" do
    mock(Pliny::RequestStore).seed.with_any_args
    get "/"
  end
end
