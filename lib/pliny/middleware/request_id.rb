# please add changes here to core's Instruments as well

module Pliny::Middleware
  class RequestID
    UUID_PATTERN =
      /\A[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}\Z/

    def initialize(app)
      @app = app
    end

    def call(env)
      request_ids = [SecureRandom.uuid] + extract_request_ids(env)

      # make ID of the request accessible to consumers down the stack
      env["REQUEST_ID"] = request_ids[0]

      # Extract request IDs from incoming headers as well. Can be used for
      # identifying a request across a number of components in SOA.
      env["REQUEST_IDS"] = request_ids

      status, headers, response = @app.call(env)

      # tag all responses with a request ID
      headers["Request-Id"] = request_ids[0]

      [status, headers, response]
    end

    private

    def extract_request_ids(env)
      request_ids = []
      if env["HTTP_REQUEST_ID"]
        request_ids = env["HTTP_REQUEST_ID"].split(",")
        request_ids.map! { |id| id.strip }
        request_ids.select! { |id| id =~ UUID_PATTERN }
      end
      request_ids
    end
  end
end
