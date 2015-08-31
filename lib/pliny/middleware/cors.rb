module Pliny::Middleware
  class CORS

    ALLOW_METHODS  =
      %w( GET POST PUT PATCH DELETE OPTIONS ).freeze
    ALLOW_HEADERS  =
      %w( Content-Type Accept AUTHORIZATION Cache-Control ).freeze
    EXPOSE_HEADERS =
      %w( Cache-Control Content-Language Content-Type Expires Last-Modified Pragma ).freeze

    def initialize(app)
      @app = app
    end

    def call(env)
      # preflight request: render a stub 200 with the CORS headers
      if cors_request?(env) && env["REQUEST_METHOD"] == "OPTIONS"
        [200, cors_headers(env), [""]]
      else
        status, headers, response = @app.call(env)

        # regualar CORS request: append CORS headers to response
        if cors_request?(env)
          headers.merge!(cors_headers(env))
        end

        [status, headers, response]
      end
    end

    def cors_request?(env)
      env.has_key?("HTTP_ORIGIN")
    end

    def cors_headers(env)
      {
        'Access-Control-Allow-Origin'      => env["HTTP_ORIGIN"],
        'Access-Control-Allow-Methods'     => ALLOW_METHODS.join(', '),
        'Access-Control-Allow-Headers'     => ALLOW_HEADERS.join(', '),
        'Access-Control-Allow-Credentials' => "true",
        'Access-Control-Max-Age'           => "1728000",
        'Access-Control-Expose-Headers'    => EXPOSE_HEADERS.join(', ')
      }
    end
  end
end
