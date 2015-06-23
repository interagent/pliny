require 'pliny/version'
require 'thor'

module Pliny::Commands
  class Generator < Thor
    desc 'endpoint NAME', 'Generates an endpoint'
    method_option :scaffold, type: :boolean, default: false, hide: true
    def endpoint(name)
      require_relative 'generator/endpoint'

      ep = Endpoint.new(name, options)
      ep.create
      ep.create_test
      ep.create_acceptance_test
    end

    desc 'mediator NAME', 'Generates a mediator'
    def mediator(name)
      require_relative 'generator/mediator'

      md = Mediator.new(name, options)
      md.create
      md.create_test
    end

    desc 'migration [NAME]', 'Generates a migration'
    def migration(*name)
      require_relative 'generator/migration'

      mg = Migration.new(name, options)
      mg.create
    end

    desc 'model NAME', 'Generates a model'
    method_option :paranoid, type: :boolean, default: false, desc: 'adds paranoid support to model'
    def model(name)
      require_relative 'generator/model'

      md = Model.new(name, options)
      md.create
      md.create_migration
      md.create_test
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

    desc 'schema NAME', 'Generates a schema'
    def schema(name)
      require_relative 'generator/schema'

      sc = Schema.new(name, options)
      sc.create
      sc.rebuild
    end

    desc 'serializer NAME', 'Generates a serializer'
    def serializer(name)
      require_relative 'generator/serializer'

      se = Serializer.new(name, options)
      se.create
      se.create_test
    end
  end
end
