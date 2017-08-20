require "logger"
require "sequel"
require "sequel/extensions/migration"

module Pliny
  class DbSupport
    def self.admin_url(database_url)
      uri = URI.parse(database_url)
      uri.path = "/postgres"
      uri.to_s
    end

    def self.setup?(database_url)
      @db = Sequel.connect(database_url)
      @db.test_connection
      @db.disconnect
      return true
    rescue Sequel::DatabaseConnectionError
      return false
    end

    def self.run(url, sequel_log_io=StringIO.new)
      logger = Logger.new(sequel_log_io)
      instance = new(url, logger)
      yield instance
      instance.disconnect
      Sequel::DATABASES.delete(instance)
    end

    attr_accessor :db

    def initialize(url, sequel_logger)
      @db = Sequel.connect(url)
      if sequel_logger
        @db.loggers << sequel_logger
      end
    end

    def exists?(name)
      res = db.fetch("SELECT 1 FROM pg_database WHERE datname = ?", name)
      return res.count > 0
    end

    def create(name)
      db.run(%{CREATE DATABASE "#{name}"})
    end

    def migrate(target=nil)
      Sequel::Migrator.apply(db, "./db/migrate", target)
    end

    def rollback
      target = timestamp_migrations_target if db.tables.include?(:schema_migrations)
      target = integer_migrations_target if db.tables.include?(:schema_info)
      Sequel::Migrator.apply(db, "./db/migrate", target) if target
    end

    def timestamp_migrations_target
      return unless current = db[:schema_migrations].order(Sequel.desc(:filename)).first
      migrations = Dir["./db/migrate/*.rb"].map { |f| File.basename(f).to_i }.sort
      target = 0 # by default, rollback everything
      index = migrations.index(current[:filename].to_i)
      target = migrations[index - 1] if index > 0
      target
    end

    def integer_migrations_target
      return unless current = db[:schema_info].first
      version = current[:version]
      target = version > 0 ? version - 1 : 0 # by default, rollback everything
      target
    end

    def disconnect
      @db.disconnect
    end
  end
end
