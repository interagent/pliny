require_relative 'generator/base'
require_relative 'generator/endpoint'
require_relative 'generator/mediator'
require_relative 'generator/migration'
require_relative 'generator/model'
require_relative 'generator/schema'
require_relative 'generator/serializer'

module Pliny::Commands
  class Generator
    attr_accessor :args, :opts, :stream

    def self.run(args, opts = {}, stream = $stdout)
      new(args, opts, stream).run!
    end

    def initialize(args = {}, opts = {}, stream = $stdout)
      @args = args
      @opts = opts
      @stream = stream
    end

    def run!
      fail 'Missing type of object to generate' unless type
      fail "Missing #{type} name" unless name

      case type
      when 'endpoint'
        opts[:scaffold] = false
        ep = Endpoint.new(name, opts)
        ep.create_endpoint
        ep.create_endpoint_test
        ep.create_endpoint_acceptance_test
      when 'mediator'
        md = Mediator.new(name, opts)
        md.create_mediator
        md.create_mediator_test
      when 'migration'
        mg = Migration.new(name, opts)
        mg.create_migration
      when 'model'
        md = Model.new(name, opts)
        md.create_model
        md.create_model_migration
        md.create_model_test
      when 'scaffold'
        opts[:scaffold] = true
        ep = Endpoint.new(name, opts)
        ep.create_endpoint
        ep.create_endpoint_test
        ep.create_endpoint_acceptance_test
        md = Model.new(name, opts)
        md.create_model
        md.create_model_migration
        md.create_model_test
        sc = Schema.new(name, opts)
        sc.create_schema
        sc.rebuild_schema
        se = Serializer.new(name, opts)
        se.create_serializer
        se.create_serializer_test
      when 'schema'
        sc = Schema.new(name, opts)
        sc.create_schema
        sc.rebuild_schema
      when 'serializer'
        se = Serializer.new(name, opts)
        se.create_serializer
        se.create_serializer_test
      else
        abort("Don't know how to generate '#{type}'.")
      end
    end

    def type
      args.first
    end

    def name
      args[1]
    end
  end
end
