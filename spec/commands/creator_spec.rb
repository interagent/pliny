# frozen_string_literal: true

require "pliny/commands/creator"
require "spec_helper"

describe Pliny::Commands::Creator do
  before do
    @gen = Pliny::Commands::Creator.new(["foobar"], {}, StringIO.new)
  end

  describe "#run!" do
    around do |example|
      Dir.mktmpdir("plinytest-") do |dir|
        Dir.chdir(dir) do
          example.run
        end
      end
    end

    it "copies the template app over" do
      @gen.run!
      assert File.exist?("./foobar")
      assert File.exist?("./foobar/Gemfile")
    end

    it "deletes the .git from it" do
      @gen.run!
      refute File.exist?("./foobar/.git")
    end

    it "deletes the .erb files from it" do
      @gen.run!
      assert_equal 0, Dir.glob("./foobar/**/{*,.*}.erb").length
    end

    it "changes DATABASE_URL in .env.sample to use the app name" do
      @gen.run!
      db_url = File.read("./foobar/.env.sample").split("\n").detect { |line|
        line.include?("DATABASE_URL=")
      }
      assert_equal "DATABASE_URL=postgres:///foobar-development", db_url
    end

    it "changes DATABASE_URL in .env.test to use the app name" do
      @gen.run!
      db_url = File.read("./foobar/.env.test").split("\n").detect { |line|
        line.include?("DATABASE_URL=")
      }
      assert_equal "DATABASE_URL=postgres:///foobar-test", db_url
    end

    it "changes APP_NAME in app.json to use the app name" do
      @gen.run!
      db_url = File.read("./foobar/app.json").split("\n").detect { |line|
        line.include?("\"name\":")
      }
      assert_equal "  \"name\": \"foobar\",", db_url
    end
  end
end
