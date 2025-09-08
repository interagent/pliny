# frozen_string_literal: true

module Pliny::Middleware
  class CORS
    ALLOW_METHODS =
      %w( GET POST PUT PATCH DELETE OPTIONS ).freeze
    ALLOW_HEADERS =
      %w( Content-Type Accept Authorization Cache-Control If-None-Match If-Modified-Since Origin).freeze
    EXPOSE_HEADERS =
      %w( Cache-Control Content-Language Content-Type Expires Last-Modified Pragma ).freeze

    @@additional_headers = []

    def self.add_additional_header(header)
      @@additional_headers << header
    end

    def initialize(app)
      @app = app
    end

    def call(env)
      # preflight request: render a stub 200 with the CORS headers
      if cors_request?(env) && env["REQUEST_METHOD"] == "OPTIONS"
        [200, cors_headers(env), [""]]
      else
        status, headers, response = @app.call(env)

        # regular CORS request: append CORS headers to response
        if cors_request?(env)
          headers.merge!(cors_headers(env))
        end

        [status, headers, response]
      end
    end

    def cors_request?(env)
      env.has_key?("HTTP_ORIGIN")
    end

    def allow_headers
      ALLOW_HEADERS + @@additional_headers
    end

    def cors_headers(env)
      {
        'access-control-allow-origin' => env["HTTP_ORIGIN"],
        'access-control-allow-methods' => ALLOW_METHODS.join(', '),
        'access-control-allow-headers' => allow_headers.join(', '),
        'access-control-allow-credentials' => "true",
        'access-control-max-age' => "1728000",
        'access-control-expose-headers' => EXPOSE_HEADERS.join(', ')
      }
    end
  end
end
