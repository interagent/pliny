# frozen_string_literal: true

require "spec_helper"

describe Pliny::Middleware::RequestStore::Seed do
  def app
    Rack::Builder.new do
      use Rack::Lint
      use Pliny::Middleware::RequestStore::Seed, store: Pliny::RequestStore
      run Sinatra.new {
        get "/" do
          "hi"
        end
      }
    end
  end

  it "seeds the store" do
    expect(Pliny::RequestStore).to receive(:seed)
    get "/"
  end
end
