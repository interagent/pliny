require 'pliny/version'
require 'thor'

module Pliny::Commands
  class Generator < Thor
    desc 'endpoint NAME', 'Generates an endpoint'
    method_option :scaffold, type: :boolean, default: false, hide: true
    def endpoint(name)
      require_relative 'generator/endpoint'
      Endpoint.new(name, options).run
    end

    desc 'mediator NAME', 'Generates a mediator'
    def mediator(name)
      require_relative 'generator/mediator'
      Mediator.new(name, options).run
    end

    desc 'migration NAME', 'Generates a migration'
    def migration(name)
      require_relative 'generator/migration'
      Migration.new(name, options).run
    end

    desc 'model NAME', 'Generates a model'
    method_option :paranoid, type: :boolean, default: false, desc: 'adds paranoid support to model'
    def model(name)
      require_relative 'generator/model'
      Model.new(name, options).run
    end

    desc 'schema NAME', 'Generates a schema'
    def schema(name)
      require_relative 'generator/schema'
      Schema.new(name, options).run
    end

    desc 'serializer NAME', 'Generates a serializer'
    def serializer(name)
      require_relative 'generator/serializer'
      Serializer.new(name, options).run
    end

    desc 'scaffold NAME', 'Generates a scaffold of endpoint, model, schema and serializer'
    method_option :paranoid, type: :boolean, default: false, desc: 'adds paranoid support to model'
    method_option :scaffold, type: :boolean, default: true, hide: true
    def scaffold(name)
      endpoint(name)
      model(name)
      schema(name)
      serializer(name)
    end
  end
end
