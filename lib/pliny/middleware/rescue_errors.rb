module Pliny::Middleware
  class RescueErrors
    def initialize(app, options = {})
      @app = app
      @raise = options[:raise]
    end

    def call(env)
      error = nil
      @app.call(env)
    rescue Pliny::Errors::Error => e
      error = e
      Pliny::Errors::Error.render(e)
    rescue => e
      error = e
      raise if @raise

      Pliny::ErrorReporters.notify(e, rack_env: env)
      Pliny::Errors::Error.render(Pliny::Errors::InternalServerError.new)
    ensure
      # Leave this in env for CanonicalLogLineEmitter.
      env["pliny.error"] = e
    end
  end
end
