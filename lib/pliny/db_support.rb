require "logger"
require "sequel"
require "sequel/extensions/migration"
require "stringio"

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

    def migrate(target = nil)
      Sequel::Migrator.apply(db, MIGRATION_DIR, target)
    end

    def version
      return 0 unless db.table_exists?(:schema_migrations)

      current = db[:schema_migrations].order(Sequel.desc(:filename)).first

      return 0 unless current

      version = current[:filename].match(Sequel::Migrator::MIGRATION_FILE_PATTERN).captures.first
      version ||= 0
      Integer(version)
    end

    class MigrationStatus
      attr_reader :filename
      attr_accessor :present_on_disk, :present_in_database

      def initialize(filename:)
        @filename = filename
        @present_on_disk = false
        @present_in_database = false
      end

      def status
        if present_on_disk
          if present_in_database
            :up
          else
            :down
          end
        else
          if present_in_database
            :file_missing
          else
            raise "error" # FIXME: better message
          end
        end
      end
    end

    def rollback
      current_version = version
      return if current_version.zero?

      migrations = Dir["#{MIGRATION_DIR}/*.rb"].map { |f| File.basename(f).to_i }.sort

      target = 0 # by default, rollback everything
      index = migrations.index(current_version)
      if index > 0
        target = migrations[index - 1]
      end
      Sequel::Migrator.apply(db, MIGRATION_DIR, target)
    end

    def disconnect
      @db.disconnect
    end

    private

    MIGRATION_DIR = "./db/migrate".freeze
    private_constant :MIGRATION_DIR
  end
end
