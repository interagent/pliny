require 'pliny/commands/updater'
require 'spec_helper'

describe Pliny::Commands::Updater do
  before do
    @io = StringIO.new
    @cmd = Pliny::Commands::Updater.new(@io)
    allow(@cmd).to receive(:exec_patch)
    Config.optional :app_name, nil
  end

  describe "#run!" do
    let(:version) { "0.6.3" }

    before do
      FileUtils.rm_rf("/tmp/plinytest")
      FileUtils.mkdir_p("/tmp/plinytest")
      Dir.chdir("/tmp/plinytest")
      File.open("/tmp/plinytest/Gemfile.lock", "w") do |f|
        f.puts "    pliny (#{version})"
      end
    end

    it "updates the templates to the latest version" do
      assert !File.exists?("./Gemfile")
      @cmd.run!
      assert File.exists?("./Gemfile")
    end

    describe "when the version is the current one" do
      let(:version) { Pliny::VERSION }

      it "doesn't do anything" do
        assert !File.exists?("./Gemfile")
        @cmd.run!
        assert !File.exists?("./Gemfile")
      end
    end
  end
end
