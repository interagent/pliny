require "erb"
require "fileutils"
require "ostruct"
require "active_support/inflector"
require "prmd"

module Pliny::Commands
  class Generator
    attr_accessor :args, :stream

    def self.run(args, stream=$stdout)
      new(args).run!
    end

    def initialize(args={}, stream=$stdout)
      @args = args
      @stream = stream
    end

    def run!
      unless type
        raise "Missing type of object to generate"
      end
      unless name
        raise "Missing #{type} name"
      end

      case type
      when "endpoint"
        create_endpoint(scaffold: false)
        create_endpoint_test
        create_endpoint_acceptance_test(scaffold: false)
      when "mediator"
        create_mediator
        create_mediator_test
      when "migration"
        create_migration
      when "model"
        create_model
        create_model_migration
        create_model_test
        create_serializer
        create_serializer_test
      when "scaffold"
        create_endpoint(scaffold: true)
        create_endpoint_test
        create_endpoint_acceptance_test(scaffold: true)
        create_model
        create_model_migration
        create_model_test
        create_schema
        rebuild_schema
        create_serializer
        create_serializer_test
      when "schema"
        create_schema
        rebuild_schema
      when "serializer"
        create_serializer
        create_serializer_test
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

    def singular_class_name
      name.singularize.camelize
    end

    def plural_class_name
      name.pluralize.camelize
    end

    def field_name
      name.tableize.singularize
    end

    def table_name
      name.tableize
    end

    def display(msg)
      stream.puts msg
    end

    def create_endpoint(options = {})
      endpoint = "./lib/endpoints/#{name.pluralize}.rb"
      template = options[:scaffold] ? "endpoint_scaffold.erb" : "endpoint.erb"
      render_template(template, endpoint, {
        plural_class_name: plural_class_name,
        singular_class_name: singular_class_name,
        field_name: field_name,
        url_path:   url_path,
      })
      display "created endpoint file #{endpoint}"
      display "add the following to lib/routes.rb:"
      display "  mount Endpoints::#{plural_class_name}"
    end

    def create_endpoint_test
      test = "./spec/endpoints/#{name.pluralize}_spec.rb"
      render_template("endpoint_test.erb", test, {
        plural_class_name: plural_class_name,
        singular_class_name: singular_class_name,
        url_path:   url_path,
      })
      display "created test #{test}"
    end

    def create_endpoint_acceptance_test(options = {})
      test = "./spec/acceptance/#{name.pluralize}_spec.rb"
      template = options[:scaffold] ? "endpoint_scaffold_acceptance_test.erb" :
        "endpoint_acceptance_test.erb"
      render_template(template, test, {
        plural_class_name: plural_class_name,
        field_name: field_name,
        singular_class_name: singular_class_name,
        url_path:   url_path,
      })
      display "created test #{test}"
    end

    def create_mediator
      mediator = "./lib/mediators/#{name}.rb"
      render_template("mediator.erb", mediator, plural_class_name: plural_class_name)
      display "created mediator file #{mediator}"
    end

    def create_mediator_test
      test = "./spec/mediators/#{name}_spec.rb"
      render_template("mediator_test.erb", test, plural_class_name: plural_class_name)
      display "created test #{test}"
    end

    def create_migration
      migration = "./db/migrate/#{Time.now.to_i}_#{name}.rb"
      render_template("migration.erb", migration)
      display "created migration #{migration}"
    end

    def create_model
      model = "./lib/models/#{name}.rb"
      render_template("model.erb", model, singular_class_name: singular_class_name)
      display "created model file #{model}"
    end

    def create_model_migration
      migration = "./db/migrate/#{Time.now.to_i}_create_#{table_name}.rb"
      render_template("model_migration.erb", migration,
        table_name: table_name)
      display "created migration #{migration}"
    end

    def create_model_test
      test = "./spec/models/#{name}_spec.rb"
      render_template("model_test.erb", test, singular_class_name: singular_class_name)
      display "created test #{test}"
    end

    def create_schema
      schema = "./docs/schema/schemata/#{name.singularize}.yaml"
      write_file(schema) do
        Prmd.init(name.singularize, yaml: true)
      end
      display "created schema file #{schema}"
    end

    def rebuild_schema
      schemata = "./docs/schema.json"
      write_file(schemata) do
        Prmd.combine("./docs/schema/schemata", meta: "./docs/schema/meta.json")
      end
      display "rebuilt #{schemata}"
    end

    def create_serializer
      serializer = "./lib/serializers/#{name}_serializer.rb"
      render_template("serializer.erb", serializer, singular_class_name: singular_class_name)
      display "created serializer file #{serializer}"
    end

    def create_serializer_test
      test = "./spec/serializers/#{name}_serializer_spec.rb"
      render_template("serializer_test.erb", test, singular_class_name: singular_class_name)
      display "created test #{test}"
    end

    def render_template(template_file, destination_path, vars={})
      template_path = File.dirname(__FILE__) + "/../templates/#{template_file}"
      template = ERB.new(File.read(template_path), 0, ">")
      context = OpenStruct.new(vars)
      write_file(destination_path) do
        template.result(context.instance_eval { binding })
      end
    end

    def url_path
      "/" + name.pluralize.gsub(/_/, '-')
    end

    def write_file(destination_path)
      FileUtils.mkdir_p(File.dirname(destination_path))
      File.open(destination_path, "w") do |f|
        f.puts yield
      end
    end
  end
end
