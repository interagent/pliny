module Pliny::Middleware
  class RescueErrors
    def initialize(app)
      @app = app
    end

    def call(env)
      @app.call(env)
    rescue Pliny::Errors::Error => e
      render(e, env)
    rescue Exception => e
    # Pliny.log_exception(e)
      render(Pliny::Errors::InternalServerError.new, env)
    end

    private

    def render(e, env)
      headers = { "Content-Type" => "application/json; charset=utf-8" }
      error = { id: e.id, message: e.message, status: e.status }
      [e.status, headers, [MultiJson.encode(error)]]
    end
  end
end
