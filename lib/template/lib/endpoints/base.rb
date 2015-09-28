module Endpoints
  # The base class for all Sinatra-based endpoints. Use sparingly.
  class Base < Sinatra::Base
    register Pliny::Extensions::Instruments
    register Sinatra::Namespace

    helpers Pliny::Helpers::Encode
    helpers Pliny::Helpers::Params

    set :dump_errors, false
    set :raise_errors, true
    set :root, Config.root
    set :show_exceptions, false

    configure :development do
      register Sinatra::Reloader
      also_reload "#{Config.root}/lib/**/*.rb"
    end

    error Sinatra::NotFound do
      raise Pliny::Errors::NotFound
    end
  end
end
