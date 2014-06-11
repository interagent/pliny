require "test_helper"

describe Pliny::Commands::Creator do
  before do
    @gen = Pliny::Commands::Creator.new(["foobar"], {}, StringIO.new)
  end

  describe "#run!" do
    before do
      FileUtils.rm_rf("/tmp/plinytest")
      FileUtils.mkdir_p("/tmp/plinytest")
      Dir.chdir("/tmp/plinytest")
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
end
