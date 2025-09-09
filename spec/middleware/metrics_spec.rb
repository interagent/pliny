# frozen_string_literal: true

require "spec_helper"

describe Pliny::Middleware::Instruments do
  def app
    Rack::Builder.new do
      run Sinatra.new {
        use Pliny::Middleware::Metrics

        get "/hello" do
          Timecop.travel(5)
          status 200
          "hi"
        end

        get "/error" do
          status 503
          "boom"
        end
      }
    end
  end

  before do
    Timecop.freeze(Time.now)
    allow(Pliny::Metrics).to receive(:count)
    allow(Pliny::Metrics).to receive(:measure)
  end

  after do
    Timecop.return
  end

  it "counts total requests" do
    expect(Pliny::Metrics).to receive(:count).with("requests").once

    get "/hello"
  end

  it "counts 2xx statuses" do
    expect(Pliny::Metrics).to receive(:count).with("requests.status.2xx").once

    get "/hello"
  end

  it "counts 4xx statuses" do
    expect(Pliny::Metrics).to receive(:count).with("requests.status.4xx").once

    get "/not-found"
  end

  it "counts 5xx statuses" do
    expect(Pliny::Metrics).to receive(:count).with("requests.status.5xx").once

    get "/error"
  end

  it "measures the request latency" do
    expect(Pliny::Metrics).to receive(:measure) do |key, opts|
      assert_equal(key, "requests.latency")
      assert_in_delta(5, opts[:value], 1)
    end

    get "/hello"
  end
end
