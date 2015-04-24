require "logger"
require "sequel"
require "sequel/extensions/migration"

module Pliny
  class DbSupport
    def self.run(url, options={})
      instance = new(url, options)
      yield instance
      instance.disconnect
    end

    attr_accessor :db

    def initialize(url, options={})
      @db = Sequel.connect(url)
      if logger = options[:logger]
        @db.loggers << logger
      end
    end

    def migrate
      Sequel::Migrator.apply(db, "./db/migrate")
    end

    def disconnect
      @db.disconnect
    end
  end
end
