require_relative 'base'

module Pliny::Commands
  class Generator
    class Migration < Base
      def initialize(name, options = {}, stream = $stdout)
        super
        @name = normalize_name(name)
      end

      def create
        migration = "./db/migrate/#{Time.now.to_i}_#{name}.rb"
        write_template('migration.erb', migration)
        display "created migration #{migration}"
      end

      private

      def normalize_name(name)
        Array(name).map(&:underscore)
                   .map { |n| n.tr(' ', '_') }
                   .join('_')
      end
    end
  end
end
