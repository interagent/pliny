require_relative 'base'

module Pliny::Commands
  class Generator
    class Serializer < Base
      def create
        serializer = "./lib/serializers/#{field_name}.rb"
        write_template('serializer.erb', serializer,
                        singular_class_name: singular_class_name)
        display "created serializer file #{serializer}"
      end

      def create_test
        test = "./spec/serializers/#{field_name}_spec.rb"
        write_template('serializer_test.erb', test,
                        singular_class_name: singular_class_name)
        display "created test #{test}"
      end
    end
  end
end
