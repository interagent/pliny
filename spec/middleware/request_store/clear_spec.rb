# frozen_string_literal: true

require "spec_helper"

describe Pliny::Middleware::RequestStore::Clear do
  def app
    Rack::Builder.new do
      use Rack::Lint
      use Pliny::Middleware::RequestStore::Clear, store: Pliny::RequestStore
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
end
