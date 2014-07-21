module Pliny::Middleware
  class RescueErrors
    def initialize(app, options = {})
      @app = app
      @raise = options[:raise]
    end

    def call(env)
      @app.call(env)
    rescue Pliny::Errors::Error => e
      Pliny::Errors::Error.render(e)
    rescue Exception => e
      if @raise
        raise
      else
        dump_error(e, env)
        Pliny::Errors::Error.render(Pliny::Errors::InternalServerError.new)
      end
    end

    private

    # pulled from Sinatra
    def dump_error(e, env)
      message = ["#{e.class} - #{e.message}:", *e.backtrace].join("\n\t")
      env['rack.errors'].puts(message)
    end
  end
end
