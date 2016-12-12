module Pliny::Middleware
  class Instruments
    class CanonicalLogLine
      include CanonicalLogLineHelpers

      log_field :error_class, String
      log_field :error_id, String
      log_field :error_message, String

      log_field :request_method, String
      log_field :request_path, String
      log_field :request_route_signature, String

      log_field :response_length, Integer
      log_field :response_status, Integer

      log_field :timing_total_elapsed, Float
    end

    def initialize(app)
      @app = app
    end

    def call(env)
      start = Time.now

      data = {
        instrumentation: true,
        method:          env["REQUEST_METHOD"],
        path:            env["PATH_INFO"]
      }

      Pliny.log(data.merge(at: "start"))

      status, headers, response = @app.call(env)

      if route = env["sinatra.route"]
        data.merge!(route_signature: route.split(" ").last)
      end

      elapsed = (Time.now - start).to_f
      Pliny.log(data.merge(
        at:              "finish",
        status:          status,
        length:          headers["Content-Length"],
        elapsed:         elapsed
      ))

      [status, headers, response]
    end
  end
end
