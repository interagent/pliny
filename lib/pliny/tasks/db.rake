require "sequel"
require "sequel/extensions/migration"
require "uri"

require "pliny/utils"

namespace :db do
  desc "Run database migrations"
  task :migrate do
    next if Dir["./db/migrate/*.rb"].empty?

    default_database_urls.each do |database_url|
      db = Sequel.connect(database_url)
      Sequel::Migrator.apply(db, "./db/migrate")
      puts "Migrated `#{name_from_uri(database_url)}`"
    end
  end

  desc "Rollback the database"
  task :rollback do
    next if Dir["./db/migrate/*.rb"].empty?

    default_database_urls.each do |database_url|
      db = Sequel.connect(default_database_url)
      Sequel::Migrator.apply(db, "./db/migrate", -1)
      puts "Rolled back `#{name_from_uri(default_database_url)}`"
    end
  end

  desc "Nuke the database (drop all tables)"
  task :nuke do
    database_urls.each do |database_url|
      db = Sequel.connect(database_url)
      db.tables.each do |table|
        db.run(%{DROP TABLE "#{table}"})
      end
      puts "Nuked `#{name_from_uri(database_url)}`"
    end
  end

  desc "Seed the database with data"
  task :seed do
    default_database_urls.each do |database_url|
      if File.exist?('./db/seeds.rb')
        Sequel.connect(database_url)
        load 'db/seeds.rb'
      end
    end
  end

  desc "Reset the database"
  task :reset => [:nuke, :migrate, :seed]

  desc "Create the database"
  task :create do
    db = Sequel.connect("postgres:///postgres")
    database_urls.each do |database_url|
      exists = false
      name = name_from_uri(database_url)
      begin
        db.run(%{CREATE DATABASE "#{name}"})
      rescue Sequel::DatabaseError
        raise unless $!.message =~ /already exists/
        exists = true
      end
      puts "Created `#{name}`" if !exists
    end
  end

  desc "Drop the database"
  task :drop do
    db = Sequel.connect("postgres:///postgres")
    database_urls.each do |database_url|
      name = name_from_uri(database_url)
      db.run(%{DROP DATABASE IF EXISTS "#{name}"})
      puts "Dropped `#{name}`"
    end
  end

  namespace :schema do
    desc "Load the database schema"
    task :load do
      default_database_urls.each do |database_url|
        schema = File.read("./db/schema.sql")
        db = Sequel.connect(database_url)
        db.run(schema)
        puts "Loaded `#{name_from_uri(database_url)}`"
      end
    end

    desc "Dump the database schema"
    task :dump do
      file = File.join("db", "schema.sql")
      `pg_dump -i -s -x -O -f #{file} #{default_database_url.first}`

      schema = File.read(file)
      # filter all COMMENT ON EXTENSION, only owners and the db
      # superuser can execute these, making it impossible to just
      # replay such statements in certain production databases
      schema.gsub!(/^COMMENT ON EXTENSION.*\n/, "")

      File.open(file, "w") { |f| f.puts schema }

      puts "Dumped `#{name_from_uri(default_database_url.first)}` to #{file}"
    end

    desc "Merges migrations into schema and removes them"
    task :merge => ["db:setup", "db:schema:load", "db:migrate", "db:schema:dump"] do
      FileUtils.rm Dir["./db/migrate/*.rb"]
      puts "Removed migrations"
    end
  end

  desc "Setup the database"
  task :setup => [:drop, :create]

  private

  def database_urls
    if ENV["DATABASE_URL"]
      Hash[ENV.map { |key, value| [key, value] if key.match(/DATABASE_URL$/) }.compact]
    else
      %w(.env .env.test).inject({}) do |i, env_file|
        env_path = "./#{env_file}"
        if File.exists?(env_path)
          Pliny::Utils.parse_env(env_path).each do |key, value|
            if key.match(/DATABASE_URL$/)
              i[key] ||= []
              i[key] << value
            end
          end
        end
        i
      end
    end
  end

  def default_database_urls
    database_urls['DATABASE_URL'] || database_urls.first
  end

  def name_from_uri(uri)
    URI.parse(uri).path[1..-1]
  end
end
