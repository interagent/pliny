require "timeout"

module Pliny::Middleware
  # Requires that Pliny::Middleware::RescueErrors is nested above it.
  class Timeout
    def initialize(app, options={})
      @app = app
      @timeout = options[:timeout] || 45
    end

    def call(env)
      ::Timeout.timeout(@timeout, RequestTimeout) do
        @app.call(env)
      end
    rescue RequestTimeout
    # Pliny::Sample.measure "requests.timeouts"
      raise Pliny::Errors::ServiceUnavailable, "Timeout reached."
    end

    # use a custom Timeout class so it can't be rescued accidentally by
    # internal calls
    class RequestTimeout < Exception
    end
  end
end
