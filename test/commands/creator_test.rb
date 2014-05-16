require "test_helper"

describe Pliny::Commands::Creator do
  before do
    @gen = Pliny::Commands::Creator.new(["foobar"], StringIO.new)
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
  end
end
