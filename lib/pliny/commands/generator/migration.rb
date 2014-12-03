require_relative 'base'

module Pliny::Commands
  class Generator
    class Migration < Base
      def create
        migration = "./db/migrate/#{Time.now.to_i}_#{name}.rb"
        write_template('migration.erb', migration)
        display "created migration #{migration}"
      end
    end
  end
end
