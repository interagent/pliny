require "logger"
require "sequel"
require "sequel/extensions/migration"

module Pliny
  class DbSupport
    @@logger = nil

    def self.logger=(logger)
      @@logger=logger
    end

    def self.run(url)
      instance = new(url)
      yield instance
      instance.disconnect
    end

    attr_accessor :db

    def initialize(url)
      @db = Sequel.connect(url)
      if @@logger
        @db.loggers << @@logger
      end
    end

    def migrate(target=nil)
      Sequel::Migrator.apply(db, "./db/migrate", target)
    end

    def rollback
      return unless db.tables.include?(:schema_migrations)
      return unless current = db[:schema_migrations].order(Sequel.desc(:filename)).first

      migrations = Dir["./db/migrate/*.rb"].map { |f| File.basename(f).to_i }.sort
      target     = 0 # by default, rollback everything
      index      = migrations.index(current[:filename].to_i)
      if index > 0
        target = migrations[index - 1]
      end
      Sequel::Migrator.apply(db, "./db/migrate", target)
    end

    def disconnect
      @db.disconnect
    end
  end
end
