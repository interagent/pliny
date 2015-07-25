require_relative 'base'
require_relative 'endpoint'
require_relative 'mediator'
require_relative 'migration'
require_relative 'model'
require_relative 'schema'
require_relative 'serializer'

module Pliny::Commands
  class Generator
    class Scaffold < Base
      def run
        [
          Endpoint,
          Mediator,
          Migration,
          Model,
          Schema,
          Serializer
        ].each do |generator|
          generator.new(name, options).run
        end
      end
    end
  end
end
