module Pliny::Middleware
  class CORS

    ALLOW_METHODS  =
      %w( GET POST PUT PATCH DELETE OPTIONS ).freeze
    ALLOW_HEADERS  =
      %w( Content-Type Accept Authorization Cache-Control If-None-Match If-Modified-Since Origin).freeze
    EXPOSE_HEADERS =
      %w( Cache-Control Content-Language Content-Type Expires Last-Modified Pragma ).freeze

    def initialize(app, allow_methods: ALLOW_METHODS,
                   allow_headers: ALLOW_HEADERS)
      @app = app
      @allow_methods = allow_methods
      @allow_headers = allow_headers
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
        'Access-Control-Allow-Methods'     => @allow_methods.join(', '),
        'Access-Control-Allow-Headers'     => @allow_headers.join(', '),
        'Access-Control-Allow-Credentials' => "true",
        'Access-Control-Max-Age'           => "1728000",
        'Access-Control-Expose-Headers'    => EXPOSE_HEADERS.join(', ')
      }
    end
  end
end
