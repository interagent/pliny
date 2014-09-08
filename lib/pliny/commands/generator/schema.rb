require_relative 'base'
require 'prmd'

module Pliny::Commands
  class Generator
    class Schema < Base
      def create
        schema = "./docs/schema/schemata/#{field_name}.yaml"
        write_file(schema) do
          Prmd.init(name.singularize, yaml: true)
        end
        display "created schema file #{schema}"
      end

      def rebuild
        schemata = './docs/schema.json'
        write_file(schemata) do
          Prmd.combine('./docs/schema/schemata', meta: './docs/schema/meta.json')
        end
        display "rebuilt #{schemata}"
      end
    end
  end
end
