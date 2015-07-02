require 'pliny/commands/updater'
require 'spec_helper'

describe Pliny::Commands::Updater do
  before do
    @io = StringIO.new
    @cmd = Pliny::Commands::Updater.new(@io)

    stub(@cmd).exec_patch
  end

  describe "#run!" do
    before do
      FileUtils.rm_rf("/tmp/plinytest")
      FileUtils.mkdir_p("/tmp/plinytest")
      Dir.chdir("/tmp/plinytest")
      File.open("/tmp/plinytest/Gemfile.lock", "w") do |f|
        f.puts "    pliny (0.6.3)"
      end
    end

    it "creates a patch with Pliny diffs between the two versions" do
      @cmd.run!
      patch = File.read(@cmd.patch_file)
      assert patch.include?('--- a/Gemfile')
      assert patch.include?('-gem "pliny", "~> 0.6"')
    end
  end
end
