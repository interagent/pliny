require 'thor'
require_relative 'generator/base'
require_relative 'generator/endpoint'
require_relative 'generator/mediator'
require_relative 'generator/migration'
require_relative 'generator/model'
require_relative 'generator/schema'
require_relative 'generator/serializer'

module Pliny::Commands
  class Generator < Thor
    desc 'endpoint NAME', 'generates an endpoint'
    def endpoint(name)
      ep = Endpoint.new(name, scaffold: false)
      ep.create_endpoint
      ep.create_endpoint_test
      ep.create_endpoint_acceptance_test
    end

    desc 'mediator NAME', 'generates a mediator'
    def mediator(name)
      md = Mediator.new(name, options)
      md.create_mediator
      md.create_mediator_test
    end

    desc 'migration NAME', 'generates a migration'
    def migration(name)
      mg = Migration.new(name, options)
      mg.create_migration
    end

    desc 'model NAME', 'generates a model'
    method_options \
      paranoid: :boolean,
      aliases: '-p',
      default: false,
      desc: 'adds paranoid support to model'
    def model(name)
      md = Model.new(name, options)
      md.create_model
      md.create_model_migration
      md.create_model_test
    end

    desc 'scaffold NAME', 'generates a scaffold of endpoint, model, schema and serializer'
    def scaffold(name)
      ep = Endpoint.new(name, scaffold: true)
      ep.create_endpoint
      ep.create_endpoint_test
      ep.create_endpoint_acceptance_test
      md = Model.new(name, scaffold: true)
      md.create_model
      md.create_model_migration
      md.create_model_test
      sc = Schema.new(name, scaffold: true)
      sc.create_schema
      sc.rebuild_schema
      se = Serializer.new(name, scaffold: true)
      se.create_serializer
      se.create_serializer_test
    end

    desc 'schema NAME', 'generates a schema'
    def schema(name)
      sc = Schema.new(name, options)
      sc.create_schema
      sc.rebuild_schema
    end

    desc 'serializer NAME', 'generates a serializer'
    def serializer(name)
      se = Serializer.new(name, options)
      se.create_serializer
      se.create_serializer_test
    end
  end
end
