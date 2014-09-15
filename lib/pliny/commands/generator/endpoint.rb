require_relative 'base'

module Pliny::Commands
  class Generator
    class Endpoint < Base
      def create
        endpoint = "./lib/endpoints/#{pluralized_file_name}.rb"
        template = options[:scaffold] ? 'endpoint_scaffold.erb' : 'endpoint.erb'
        render_template(template, endpoint,
                        plural_class_name: plural_class_name,
                        singular_class_name: singular_class_name,
                        field_name: field_name,
                        url_path: url_path)
        display "created endpoint file #{endpoint}"
        display 'add the following to lib/routes.rb:'
        display "  mount Endpoints::#{plural_class_name}"
      end

      def create_test
        test = "./spec/endpoints/#{pluralized_file_name}_spec.rb"
        render_template('endpoint_test.erb', test,
                        plural_class_name: plural_class_name,
                        singular_class_name: singular_class_name,
                        url_path: url_path)
        display "created test #{test}"
      end

      def create_acceptance_test
        test = "./spec/acceptance/#{pluralized_file_name}_spec.rb"
        template = options[:scaffold] ? 'endpoint_scaffold_acceptance_test.erb' : 'endpoint_acceptance_test.erb'
        render_template(template, test,
                        plural_class_name: plural_class_name,
                        field_name: field_name,
                        singular_class_name: singular_class_name,
                        url_path: url_path)
        display "created test #{test}"
      end

      def url_path
        '/' + name.pluralize.tr('_', '-')
      end
    end
  end
end
