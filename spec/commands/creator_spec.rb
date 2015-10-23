require 'pliny/commands/creator'
require 'spec_helper'

describe Pliny::Commands::Creator do
  before do
    @gen = Pliny::Commands::Creator.new(["foobar"], {}, StringIO.new)
  end

  describe "#run!" do
    around do |example|
      FileUtils.rm_rf("tmp/plinytest")
      FileUtils.mkdir_p("tmp/plinytest")
      Dir.chdir("tmp/plinytest") do
        example.run
      end
    end

    it "copies the template app over" do
      @gen.run!
      assert File.exists?("./foobar")
      assert File.exists?("./foobar/Gemfile")
    end

    it "deletes the .git from it" do
      @gen.run!
      refute File.exists?("./foobar/.git")
    end

    context "without docker" do
      it "changes DATABASE_URL in .env.sample to use the app name" do
        @gen.run!
        db_url = File.read("./foobar/.env.sample").split("\n").detect do |line|
          line.include?("DATABASE_URL=")
        end
        assert_equal "DATABASE_URL=postgres:///foobar-development", db_url
      end

      it "changes DATABASE_URL in .env.test to use the app name" do
        @gen.run!
        db_url = File.read("./foobar/.env.test").split("\n").detect do |line|
          line.include?("DATABASE_URL=")
        end
        assert_equal "DATABASE_URL=postgres:///foobar-test", db_url
      end
    end

    context "with docker" do
      before do
        @gen = Pliny::Commands::Creator.new(["foobar"], {docker: true}, StringIO.new)
      end

      it "changes DATABASE_URL in .env.sample to use the app name" do
        @gen.run!
        db_url = File.read("./foobar/.env.sample").split("\n").detect do |line|
          line.include?("DATABASE_URL=")
        end
        assert_equal "DATABASE_URL=postgres://postgres@postgres/foobar-development", db_url
      end

      it "changes DATABASE_URL in .env.test to use the app name" do
        @gen.run!
        db_url = File.read("./foobar/.env.test").split("\n").detect do |line|
          line.include?("DATABASE_URL=")
        end
        assert_equal "DATABASE_URL=postgres://postgres@postgres/foobar-test", db_url
      end
    end
  end
end
