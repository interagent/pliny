# frozen_string_literal: true

module Pliny::Middleware::RequestStore
  class Clear
    def initialize(app, options={})
      @app = app
      @store = options[:store] || Pliny::RequestStore
    end

    def call(env)
      @store.clear!
      @app.call(env)
    end
  end
end
