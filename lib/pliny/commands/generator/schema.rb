require_relative 'base'
require 'prmd'

module Pliny::Commands
  class Generator
    class Schema < Base
      def create
        schema = "./schema/schemata/#{field_name}.yaml"
        write_file(schema) do
          Prmd.init(name.singularize, yaml: true)
        end
        display "created schema file #{schema}"
      end

      def rebuild
        schemata = './schema/schema.json'
        write_file(schemata) do
          Prmd.combine('./schema/schemata', meta: './schema/meta.json')
        end
        display "rebuilt #{schemata}"
      end
    end
  end
end
