# frozen_string_literal: true

module Pliny::Middleware
  # Emits a "canonical log line", i.e. a single log line that contains as much
  # relevant information about a request as possible and which makes for a
  # single convenient reference point to understand all the vitals of any
  # single request.
  #
  # This default implementation contains some useful data to get a project
  # started, but it's usually recommended to vendor this middleware into your
  # project and start adding some custom fields. Some examples of those might
  # be:
  #
  #     * ID and email of an authenticated user.
  #     * ID of API key used, OAuth application and scope.
  #     * Remaining and total rate limits.
  #     * Name of the service, HEAD revision, release number.
  #     * Name of the internal system that initiated the request.
  #
  class CanonicalLogLine
    # LogLine is a nested model that allows us to construct a canonical log
    # line in a way that's reasonably well organized and somewhat type safe.
    # It's responsible for hashifying its defined fields for emission into a
    # log stream or elsewhere.
    class LogLine
      include Pliny::CanonicalLogLineHelpers

      #
      # error
      #

      log_field :error_class, String
      log_field :error_id, String
      log_field :error_message, String

      #
      # request
      #

      log_field :request_id, String
      log_field :request_method, String
      log_field :request_ip, String
      log_field :request_path, String
      log_field :request_route_signature, String
      log_field :request_user_agent, String

      #
      # response
      #

      log_field :response_length, Integer
      log_field :response_status, Integer
      log_field :serializer_arity, Integer

      #
      # timing
      #

      log_field :timing_total_elapsed, Float
      log_field :timing_serializer, Float
    end

    def initialize(app, options)
      @app = app
      @emitter = options.fetch(:emitter)
    end

    def call(env)
      begin
        start = Time.now
        status, headers, response = @app.call(env)
      ensure
        begin
          line = LogLine.new

          #
          # error
          #

          if (error = env["pliny.error"])
            line.error_class = error.class.name
            line.error_message = error.message
            if error.is_a?(Pliny::Errors::Error)
              line.error_id = error.id.to_s
            end
          end

          #
          # request
          #

          request = Rack::Request.new(env)
          line.request_id = env["REQUEST_ID"]
          line.request_ip = request.ip
          line.request_method = request.request_method
          line.request_path = request.path_info
          line.request_user_agent = request.user_agent
          if (route = env["sinatra.route"])
            line.request_route_signature = route.split(" ").last
          end

          #
          # response
          #

          if (length = headers["Content-Length"])
            line.response_length = length.to_i
          end
          line.response_status = status
          line.serializer_arity = env["pliny.serializer_arity"]

          #
          # timing
          #

          line.timing_total_elapsed = (Time.now - start).to_f
          line.timing_serializer = env["pliny.serializer_timing"]

          @emitter.call(line.to_h)
        rescue => e
          # We hope that a canonical log line never fails, but in case it
          # does, do not fail the request because it did.
          Pliny.log(message: "Failed to emit canonical log line")
          Pliny::ErrorReporters.notify(e, rack_env: env)
        end
      end

      [status, headers, response]
    end
  end
end
