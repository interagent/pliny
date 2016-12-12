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
  class CanonicalLogLineEmitter
    class CanonicalLogLine
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

      #
      # timing
      #

      log_field :timing_total_elapsed, Float
    end

    def initialize(app, emitter:)
      @app = app
      @emitter = emitter
    end

    def call(env)
      begin
        start = Time.now
        status, headers, response = @app.call(env)
      ensure
        line = CanonicalLogLine.new

        #
        # error
        #

        if error = env["pliny.error"]
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
        if route = env["sinatra.route"]
          line.request_route_signature = route.split(" ").last
        end

        #
        # response
        #

        if length = headers["Content-Length"]
          line.response_length = length.to_i
        end
        line.response_status = status

        #
        # timing
        #

        line.timing_total_elapsed = (Time.now - start).to_f

        @emitter.call(line.to_h)
      end

      [status, headers, response]
    end
  end
end
