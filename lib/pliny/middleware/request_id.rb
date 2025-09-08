# frozen_string_literal: true

# please add changes here to core's Instruments as well

module Pliny::Middleware
  class RequestID
    # note that this pattern supports either a full UUID, or a "squashed" UUID
    # like the kind Hermes sends:
    #
    #     full:     01234567-89ab-cdef-0123-456789abcdef
    #     squashed: 0123456789abcdef0123456789abcdef
    #
    UUID_PATTERN =
      /\A[a-f0-9]{8}-?[a-f0-9]{4}-?[a-f0-9]{4}-?[a-f0-9]{4}-?[a-f0-9]{12}\Z/

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
      request_ids = raw_request_ids(env)
      request_ids.map! { |id| id.strip }
      request_ids.select! { |id| id =~ UUID_PATTERN }
      request_ids
    end

    def raw_request_ids(env)
      # We had a little disagreement around the inception of the Request-Id
      # field as to whether it should be prefixed with `X-` or not. API went
      # with no prefix, but Hermes went with one. Support both formats on
      # input.
      %w(HTTP_REQUEST_ID HTTP_X_REQUEST_ID).inject([]) do |request_ids, key|
        if ids = env[key]
          request_ids += ids.split(",")
        end
        request_ids
      end
    end
  end
end
