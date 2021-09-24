require "spec_helper"
require "open3"
require 'active_support/core_ext/object/blank'

describe "Pliny integration test" do
  before(:all) do
    @original_dir = Dir.pwd

    test_dir = Dir.mktmpdir("plinytest-")
    Dir.chdir(test_dir)

    bash "pliny-new myapp"

    Dir.chdir("myapp")
    bash "bin/setup"
  end

  after(:all) do
    Dir.chdir(@original_dir)
  end

  describe "bin/setup" do
    it "generates .env" do
      assert File.exist?("./.env")
    end
  end

  describe "pliny-generate scaffold" do
    before(:all) do
      bash "pliny-generate scaffold artist"
    end

    it "creates the model file" do
      assert File.exist?("./lib/models/artist.rb")
    end

    it "creates the endpoint file" do
      assert File.exist?("./lib/endpoints/artists.rb")
    end

    it "creates the serializer file" do
      assert File.exist?("./lib/serializers/artist.rb")
    end

    it "creates the schema file" do
      assert File.exist?("./schema/schemata/artist.yaml")
    end
  end

  describe "rake db:migrate:status" do
    it "returns a migration in the DOWN state when not migrated" do
      DB.tables.each { |t| DB.drop_table(t) }

      bash "pliny-generate model artist"
      migration_file = Dir.glob('db/migrate/*').first

      stdout, stderr = bash_with_output("rake db:migrate:status")

      statuses = Hash[stdout.to_s.split(/\+[-]+\+[-]+\+/)[2..].map { |s| s.tr("\n", "") }.select(&:present?).map { |s| s.split("|").map { |s| s.tr(" ", "") }.select(&:present?).reverse }]
      assert statuses[migration_file.split("/").last] == "DOWN"
    end

    it "returns a migration in the UP state when not migrated" do
      DB.tables.each { |t| DB.drop_table(t) }

      bash "pliny-generate model artist"
      migration_file = Dir.glob('db/migrate/*').first
      bash "rake db:migrate"

      stdout, stderr = bash_with_output("rake db:migrate:status")

      statuses = Hash[stdout.to_s.split(/\+[-]+\+[-]+\+/)[2..].map { |s| s.tr("\n", "") }.select(&:present?).map { |s| s.split("|").map { |s| s.tr(" ", "") }.select(&:present?).reverse }]
      assert statuses[migration_file.split("/").last] == "UP"
    end

    it "returns a migration in the FILE MISSING state when the file is missing" do
      DB.tables.each { |t| DB.drop_table(t) }

      bash "pliny-generate model artist"
      migration_file = Dir.glob('db/migrate/*').first
      bash "rake db:migrate"

      FileUtils.rm_f(migration_file)

      stdout, stderr = bash_with_output("rake db:migrate:status")

      statuses = Hash[stdout.to_s.split(/\+[-]+\+[-]+\+/)[2..].map { |s| s.tr("\n", "") }.select(&:present?).map { |s| s.split("|").map { |s| s.gsub(/(^[ ]+|[ ]+$)/, "") }.select(&:present?).reverse }]
      assert statuses[migration_file.split("/").last] == "FILE MISSING"
    end
  end

  def bash_with_output(cmd)
    bin  = File.expand_path('../bin', File.dirname(__FILE__))
    path = "#{bin}:#{ENV["PATH"]}"
    env = { "PATH" => path }
    stdout, stderr, status = Open3.capture3(env, cmd)

    unless status.success?
      raise "Failed to run #{cmd}, error was #{stderr}"
    end

    return stdout, stderr
  end

  def bash(cmd)
    bin  = File.expand_path('../bin', File.dirname(__FILE__))
    path = "#{bin}:#{ENV["PATH"]}"
    env = { "PATH" => path }
    unless system(env, "#{cmd} > /dev/null")
      raise "Failed to run #{cmd}"
    end
  end
end
