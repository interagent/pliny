# frozen_string_literal: true

module Pliny::Middleware::RequestStore
  class Seed
    def initialize(app, options = {})
      @app = app
      @store = options[:store] || Pliny::RequestStore
    end

    def call(env)
      @store.seed(env)
      @app.call(env)
    end
  end
end
