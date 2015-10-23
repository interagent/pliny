require "spec_helper"

describe "Pliny w/ docker integration test" do
  around(:each) do |example|
    FileUtils.rm_rf("tmp/plinytest")
    FileUtils.mkdir_p("tmp/plinytest")
    Dir.chdir("tmp/plinytest") do
      bash "pliny-new myapp --docker"
      bash_app "docker-compose run web bin/setup"
      example.run
    end
  end

  describe "bin/setup" do
    it "generates .env" do
      assert File.exists?("./myapp/.env")
    end
  end

  describe "pliny-generate model" do
    before do
      bash_app "pliny-generate model artist"
    end

    it "creates the model file" do
      assert File.exists?("./myapp/lib/models/artist.rb")
    end
  end

  def bash(cmd)
    bin  = File.expand_path('../../bin', File.dirname(__FILE__))
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
