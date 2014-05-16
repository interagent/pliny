require "test_helper"

describe "Pliny integration test" do
  before do
    FileUtils.rm_rf("/tmp/plinytest")
    FileUtils.mkdir_p("/tmp/plinytest")
    Dir.chdir("/tmp/plinytest")
  end

  it "works" do
    Pliny::Commands::Creator.run(["myapp"], StringIO.new)
    bash "bin/setup"
    assert File.exists?("./myapp/Gemfile.lock")
  end

  def bash(cmd)
    unless system("cd myapp && #{cmd} > /dev/null")
      raise "Failed to run #{cmd}"
    end
  end
end