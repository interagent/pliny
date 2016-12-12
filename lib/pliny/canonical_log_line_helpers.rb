module Pliny
  module CanonicalLogLineHelpers
    module ClassMethods
      def log_field(name, type)
        unless name.is_a?(Symbol)
          raise ArgumentError, "Expected first argument to be a symbol"
        end

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

      unless val.is_a?(type)
        raise ArgumentError, "Expected #{name} to be type #{type}"
      end

      @values[name] = value
    end
  end
end
