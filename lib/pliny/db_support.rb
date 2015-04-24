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

    def migrate
      Sequel::Migrator.apply(db, "./db/migrate")
    end

    def rollback
      migrations = Dir["./db/migrate/*.rb"].map { |f| File.basename(f).to_i }.sort
      current = db[:schema_migrations].order(Sequel.desc(:filename)).first[:filename].to_i
      target = 0 # by default, rollback everything
      if i = migrations.index(current)
        target = migrations[i - 1] || 0
      end
      Sequel::Migrator.apply(db, "./db/migrate", target)
    end

    def disconnect
      @db.disconnect
    end
  end
end
