# frozen_string_literal: true

require "spec_helper"

describe Pliny::Helpers::Encode do
  def app
    Sinatra.new do
      helpers Pliny::Helpers::Encode
      post "/" do
        encode(params)
      end
    end
  end

  before do
    allow(Config).to receive(:pretty_json) { false }
  end

  it "sets the Content-Type" do
    post "/"
    assert_equal "application/json;charset=utf-8",
      last_response.headers["Content-Type"]
  end

  it "encodes as json" do
    payload = { "foo" => "bar" }
    post "/", payload
    assert_equal JSON.generate(payload), last_response.body
  end

  it "encodes in pretty mode when pretty=true" do
    payload = { "foo" => "bar", "pretty" => "true" }
    post "/", payload
    assert_equal JSON.pretty_generate(payload), last_response.body
  end

  it "encodes in pretty mode when set by config" do
    allow(Config).to receive(:pretty_json) { true }
    payload = { "foo" => "bar" }
    post "/", payload
    assert_equal JSON.pretty_generate(payload), last_response.body
  end
end
