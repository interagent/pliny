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
      Pliny::Errors::Error.render(e)
    rescue => e
      raise if @raise

      Pliny::ErrorReporters.notify(e, rack_env: env)
      Pliny::Errors::Error.render(Pliny::Errors::InternalServerError.new(@message))
    end
  end
end
