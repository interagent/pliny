# frozen_string_literal: true

module Pliny
  # Helpers to produce a canonical log line. This mostly amounts to a set of
  # accessors that do basic type checking combined with tracking an internal
  # schema so that we can produce a hash of everything that's been set so far.
  module CanonicalLogLineHelpers
    module ClassMethods
      def log_field(name, type)
        unless name.is_a?(Symbol)
          raise ArgumentError, "Expected first argument to be a symbol"
        end

        @fields ||= {}
        @fields[name] = type
        define_method(:"#{name}=") do |val|
          set_field(name, val)
        end
      end
    end

    def self.included(klass)
      klass.extend(ClassMethods)
    end

    def to_h
      @values
    end

    private

    def set_field(name, value)
      type = self.class.instance_variable_get(:@fields)[name]

      unless type
        raise ArgumentError, "Field #{name} undefined"
      end

      if !value.nil? && !value.is_a?(type)
        raise ArgumentError,
          "Expected #{name} to be type #{type} (was #{value.class.name})"
      end

      @values ||= {}
      @values[name] = value
    end
  end
end
