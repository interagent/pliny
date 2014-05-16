require "test_helper"

describe "Pliny integration test" do
  before do
    FileUtils.rm_rf("/tmp/plinytest")
    FileUtils.mkdir_p("/tmp/plinytest")
    Dir.chdir("/tmp/plinytest")
  end

  it "works" do
    bash "pliny-new myapp"
    bash_app "bin/setup"
    assert File.exists?("./myapp/Gemfile.lock")
    bash_app "pliny-generate model artist"
    assert File.exists?("./myapp/lib/models/artist.rb")
    # could use something like bin/run in the template app to facilitate testing this
  end

  def bash(cmd)
    bin  = File.expand_path('../bin', File.dirname(__FILE__))
    path = "#{bin}:#{ENV["PATH"]}"
    env = { "PATH" => path }
    unless system(env, "#{cmd} > /dev/null")
      raise "Failed to run #{cmd}"
    end
  end

  def bash_app(cmd)
    bash "cd myapp && #{cmd}"
  end
end