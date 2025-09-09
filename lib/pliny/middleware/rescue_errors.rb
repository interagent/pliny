# frozen_string_literal: true

module Pliny::Middleware
  class RescueErrors
    def initialize(app, options = {})
      @app = app
      @raise = options[:raise]
      @message = options[:message]
    end

    def call(env)
      @app.call(env)
    rescue Pliny::Errors::Error => e
      set_error_in_env(env, e)
      Pliny::Errors::Error.render(e)
    rescue => e
      set_error_in_env(env, e)
      raise if @raise

      Pliny::ErrorReporters.notify(e, rack_env: env)
      Pliny::Errors::Error.render(Pliny::Errors::InternalServerError.new(@message))
    end

    # Sets the error in a predefined env key for use by the upstream
    # CanonicalLogLine middleware.
    def set_error_in_env(env, e)
      env["pliny.error"] = e
    end
  end
end
