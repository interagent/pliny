# frozen_string_literal: true

module Serializers
  class Base
    extend Pliny::Helpers::ZuluTime

    @@structures = {}

    def self.structure(type, &blk)
      @@structures["#{name}::#{type}"] = blk
    end

    def initialize(type)
      @type = type
    end

    def serialize(object)
      object.respond_to?(:map) ? object.map { |item| serializer.call(item) } : serializer.call(object)
    end

    private

    def serializer
      @@structures["#{self.class.name}::#{@type}"]
    end
  end
end
