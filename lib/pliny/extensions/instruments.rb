module Pliny::Extensions
  module Instruments
    def self.registered(app)
      app.before do
        @request_start = Time.now
        Pliny.log(
          instrumentation: true,
          at:              "start",
          method:          request.request_method,
          path:            request.path_info,
        )
      end

      app.after do
        Pliny.log(
          instrumentation: true,
          at:              "finish",
          method:          request.request_method,
          path:            request.path_info,
          route_signature: route_signature,
          status:          status,
          elapsed:         (Time.now - @request_start).to_f
        )
      end

      app.helpers do
        def route_signature
          env["ROUTE_SIGNATURE"]
        end
      end
    end

    def route(verb, path, *)
      condition { env["ROUTE_SIGNATURE"] = path.to_s }
      super
    end
  end
end
