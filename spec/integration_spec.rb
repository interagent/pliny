require "spec_helper"

describe "Pliny integration test" do
  before(:all) do
    FileUtils.rm_rf("/tmp/plinytest")
    FileUtils.mkdir_p("/tmp/plinytest")
    Dir.chdir("/tmp/plinytest")

    bash "pliny-new myapp"

    Dir.chdir("/tmp/plinytest/myapp")
    bash "bin/setup"
  end

  describe "bin/setup" do
    it "generates .env" do
      assert File.exists?("./.env")
    end
  end

  describe "pliny-generate scaffold" do
    before(:all) do
      bash "pliny-generate scaffold artist"
    end

    it "creates the model file" do
      assert File.exists?("./lib/models/artist.rb")
    end

    it "creates the endpoint file" do
      assert File.exists?("./lib/endpoints/artists.rb")
    end

    it "creates the serializer file" do
      assert File.exists?("./lib/serializers/artist.rb")
    end

    it "creates the schema file" do
      assert File.exists?("./schema/schemata/artist.yaml")
    end
  end

  def bash(cmd)
    bin  = File.expand_path('../bin', File.dirname(__FILE__))
    path = "#{bin}:#{ENV["PATH"]}"
    env = { "PATH" => path }
    unless system(env, "#{cmd} > /dev/null")
      raise "Failed to run #{cmd}"
    end
  end
end
