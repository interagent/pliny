module Pliny::Commands
  class Generator
    class Migration < Base
      def create_migration
        migration = "./db/migrate/#{Time.now.to_i}_#{name}.rb"
        render_template('migration.erb', migration)
        display "created migration #{migration}"
      end
    end
  end
end
