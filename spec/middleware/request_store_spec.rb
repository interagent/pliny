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
    expect(Pliny::RequestStore).to receive(:clear!)
    get "/"
  end

  it "seeds the store" do
    expect(Pliny::RequestStore).to receive(:seed)
    get "/"
  end
end
