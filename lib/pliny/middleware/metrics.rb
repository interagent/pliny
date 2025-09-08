# frozen_string_literal: true

module Pliny::Middleware
  class Metrics
    def initialize(app)
      @app = app
    end

    def call(env)
      start = Time.now

      Pliny::Metrics.count("requests")

      begin
        status, headers, body = @app.call(env)
      rescue
        status = 500
        raise
      ensure
        elapsed = (Time.now - start).to_f
        Pliny::Metrics.measure("requests.latency", value: elapsed)

        status_level = "#{status/100}xx"
        Pliny::Metrics.count("requests.status.#{status_level}")
      end

      [status, headers, body]
    end
  end
end
