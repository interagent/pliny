require_relative 'base'
require 'prmd'

module Pliny::Commands
  class Generator
    class Schema < Base
      def initialize(*)
        super
        @warned_legacy = false
      end

      def run
        create_schema
        rebuild
      end

      def rebuild
        warn_legacy if legacy?

        write_file(schema_json_path) do
          Prmd.combine(schemata_path, meta: meta_path)
        end
        display "rebuilt #{schema_json_path}"
      end

      private

      def create_schema
        warn_legacy if legacy?

        schema = schema_yaml_path(field_name)
        write_file(schema) do
          Prmd.init(name.singularize, yaml: true)
        end
        display "created schema file #{schema}"
      end

      def legacy?
        File.exist?("./docs/schema.json") || File.directory?("./docs/schema/schemata")
      end

      def warn_legacy
        return if @warned_legacy
        display "WARNING: Using legacy schema layout under docs/. To use new layout under schema/, run `mkdir -p schema && git mv docs/schema.json docs/schema/meta.* docs/schema/schemata schema` then check for remaining schema-related files under docs/."
        @warned_legacy = true
      end

      def schema_json_path
        if legacy?
          "./docs/schema.json"
        else
          "./schema/schema.json"
        end
      end

      def meta_path
        if legacy?
          "./docs/schema/meta.json"
        else
          "./schema/meta.json"
        end
      end

      def schemata_path
        if legacy?
          "./docs/schema/schemata"
        else
          "./schema/schemata"
        end
      end

      def schema_base
        Pathname.new("./schema")
      end

      def schema_yaml_path(field_name)
        File.join(schemata_path, "#{field_name}.yaml")
      end
    end
  end
end
