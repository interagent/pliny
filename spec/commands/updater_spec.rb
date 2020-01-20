require "pliny/commands/updater"
require "spec_helper"

describe Pliny::Commands::Updater do
  before do
    @io = StringIO.new
    @cmd = Pliny::Commands::Updater.new(@io)

    allow(@cmd).to receive(:exec_patch)
  end

  describe "#run!" do
    around do |example|
      Dir.mktmpdir("plinytest-") do |dir|
        Dir.chdir(dir) do
          File.open("./Gemfile.lock", "w") do |f|
            f.puts "    pliny (0.6.3)"
          end
          example.run
        end
      end
    end

    it "creates a patch with Pliny diffs between the two versions" do
      @cmd.run!
      patch = File.read(@cmd.patch_file)
      assert patch.include?("--- a/Gemfile")
      assert patch.include?('-gem "pliny", "~> 0.6"')
    end
  end
end
