module Pliny::Middleware
  class Instruments
    def initialize(app)
      @app = app
    end

    def call(env)
      start = Time.now

      request_ids = env["REQUEST_IDS"] ? env["REQUEST_IDS"].join(",") : nil

      data = {
        request_id:      request_ids,
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
