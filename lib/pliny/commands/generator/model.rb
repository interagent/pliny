require_relative 'base'

module Pliny::Commands
  class Generator
    class Model < Base
      def create
        model = "./lib/models/#{field_name}.rb"
        write_template('model.erb', model,
                        singular_class_name: singular_class_name,
                        paranoid: options[:paranoid])
        display "created model file #{model}"
      end

      def create_migration
        migration = "./db/migrate/#{Time.now.to_i}_create_#{table_name}.rb"
        write_template('model_migration.erb', migration,
                        table_name: table_name,
                        paranoid: options[:paranoid])
        display "created migration #{migration}"
      end

      def create_test
        test = "./spec/models/#{field_name}_spec.rb"
        write_template('model_test.erb', test,
                        singular_class_name: singular_class_name)
        display "created test #{test}"
      end
    end
  end
end
