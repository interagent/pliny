# frozen_string_literal: true

require "spec_helper"

describe Pliny::Middleware::RequestID do
  def app
    Rack::Builder.new do
      use Rack::Lint
      use Pliny::Middleware::RequestID
      run Sinatra.new {
        get "/" do
          env["REQUEST_IDS"].join(",")
        end
      }
    end
  end

  it "tags responses with Request-Id" do
    get "/"
    assert_match Pliny::Middleware::RequestID::UUID_PATTERN,
      last_response.headers["Request-Id"]
  end

  it "accepts incoming request IDs" do
    id = SecureRandom.uuid
    header "Request-Id", id
    get "/"
    assert_includes last_response.body, id
  end

  it "accepts incoming request IDs with an `X-` prefix" do
    id = SecureRandom.uuid
    header "X-Request-Id", id
    get "/"
    assert_includes last_response.body, id
  end
end
