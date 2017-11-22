require_relative 'base'
require 'prmd'

module Pliny::Commands
  class Generator
    class Schema < Base
      def initialize(*)
        super
        @warned_legacy = false
      end

      def create
        warn_legacy if legacy?

        schema = schema_yaml_path(field_name)
        write_file(schema) do
          Prmd.init(name.singularize, yaml: true)
        end
        display "created schema file #{schema}"
      end

      def rebuild
        warn_legacy if legacy?

        write_file(schema_json_path) do
          Prmd.combine(schemata_path, meta: meta_path)
        end
        display "rebuilt #{schema_json_path}"

        Dir["#{schema_path}/variants/*"].each do |variant|
          paths = ["#{schema_path}/schemata", "#{variant}/schemata"]
          write_file("#{variant}/schema.json") do
            Prmd.combine(paths, meta: "#{schema_path}/meta.json").to_s
          end
          display "rebuilt #{variant}/schema.json"
        end
      end

      def legacy?
        File.exist?("./docs/schema.json") || File.directory?("./docs/schema/schemata")
      end

      def warn_legacy
        return if @warned_legacy
        display "WARNING: Using legacy schema layout under docs/. To use new layout under schema/, run `mkdir -p schema && git mv docs/schema.json docs/schema/meta.* docs/schema/schemata schema` then check for remaining schema-related files under docs/."
        @warned_legacy = true
      end

      def schema_path
        if legacy?
          "./docs/schema"
        else
          "./schema"
        end
      end

      def schema_json_path
        if legacy?
          "#{schema_path}.json"
        else
          "#{schema_path}/schema.json"
        end
      end

      def meta_path
        if legacy?
          "#{schema_path}/meta.json"
        else
          "#{schema_path}/meta.json"
        end
      end

      def schemata_path
        if legacy?
          "#{schema_path}/schemata"
        else
          "#{schema_path}/schemata"
        end
      end

      def schema_yaml_path(field_name)
        File.join(schemata_path, "#{field_name}.yaml")
      end
    end
  end
end
