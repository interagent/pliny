require 'active_support/inflector'
require 'ostruct'
require 'erb'
require 'fileutils'

module Pliny::Commands
  class Generator
    class Base
      attr_reader :name, :stream, :options

      def initialize(name, stream = $stdout, options = {})
        @name = name
        @stream = stream
        @options = options
      end

      def paranoid
        options[:paranoid]
      end

      def singular_class_name
        name.gsub(/-/, '_').singularize.camelize
      end

      def plural_class_name
        name.gsub(/-/, '_').pluralize.camelize
      end

      def field_name
        name.tableize.singularize
      end

      def pluralized_file_name
        name.tableize
      end

      def table_name
        name.tableize.gsub('/', '_')
      end

      def display(msg)
        stream.puts msg
      end

      def render_template(template_file, destination_path, vars = {})
        template_path = File.dirname(__FILE__) + "/../templates/#{template_file}"
        template = ERB.new(File.read(template_path), 0, '>')
        context = OpenStruct.new(vars)
        write_file(destination_path) do
          template.result(context.instance_eval { binding })
        end
      end

      def write_file(destination_path)
        FileUtils.mkdir_p(File.dirname(destination_path))
        File.open(destination_path, 'w') do |f|
          f.puts yield
        end
      end
    end
  end
end
