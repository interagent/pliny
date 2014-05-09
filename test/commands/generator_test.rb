require "test_helper"

describe Pliny::Commands::Generator do
  before do
    @gen = Pliny::Commands::Generator.new({}, StringIO.new)
  end

  describe "#plural_class_name" do
    it "builds a class name for a model" do
      @gen.args = ["model", "resource_histories"]
      assert_equal "ResourceHistories", @gen.plural_class_name
    end
  end

  describe "#singular_class_name" do
    it "builds a class name for an endpoint" do
      @gen.args = ["model", "resource_histories"]
      assert_equal "ResourceHistory", @gen.singular_class_name
    end
  end

  describe "#table_name" do
    it "uses the plural form" do
      @gen.args = ["model", "resource_history"]
      assert_equal "resource_histories", @gen.table_name
    end
  end

  describe "#run!" do
    before do
      FileUtils.mkdir_p("/tmp/plinytest")
      Dir.chdir("/tmp/plinytest")
      Timecop.freeze(@t=Time.now)
    end

    after do
      FileUtils.rmdir("/tmp/plinytest")
      Timecop.return
    end

    describe "generating endpoints" do
      before do
        @gen.args = ["endpoint", "artists"]
        @gen.run!
      end

      it "creates a new endpoint module" do
        assert File.exists?("lib/endpoints/artists.rb")
      end

      it "creates an endpoint test" do
        assert File.exists?("spec/endpoints/artists_spec.rb")
      end

      it "creates an endpoint acceptance test" do
        assert File.exists?("spec/acceptance/artists_spec.rb")
      end
    end

    describe "generating mediators" do
      before do
        @gen.args = ["mediator", "artists/creator"]
        @gen.run!
      end

      it "creates a new endpoint module" do
        assert File.exists?("lib/mediators/artists/creator.rb")
      end

      it "creates a test" do
        assert File.exists?("spec/mediators/artists/creator_spec.rb")
      end
    end

    describe "generating models" do
      before do
        @gen.args = ["model", "artist"]
        @gen.run!
      end

      it "creates a migration" do
        assert File.exists?("db/migrate/#{@t.to_i}_create_artists.rb")
      end

      it "creates the actual model" do
        assert File.exists?("lib/models/artist.rb")
      end

      it "creates a test" do
        assert File.exists?("spec/models/artist_spec.rb")
      end
    end

    describe "generating scaffolds" do
      before do
        @gen.args = ["scaffold", "artist"]
        @gen.run!
      end

      it "creates a new endpoint module" do
        assert File.exists?("lib/endpoints/artists.rb")
      end

      it "creates an endpoint test" do
        assert File.exists?("spec/endpoints/artists_spec.rb")
      end

      it "creates an endpoint acceptance test" do
        assert File.exists?("spec/acceptance/artists_spec.rb")
      end

      it "creates a migration" do
        assert File.exists?("db/migrate/#{@t.to_i}_create_artists.rb")
      end

      it "creates the actual model" do
        assert File.exists?("lib/models/artist.rb")
      end

      it "creates a test" do
        assert File.exists?("spec/models/artist_spec.rb")
      end

      it "creates a schema" do
        assert File.exists?("docs/schema/schemata/artist.yaml")
      end
    end

    describe "generating schemas" do
      before do
        @gen.args = ["schema", "artist"]
        @gen.run!
      end

      it "creates a schema" do
        assert File.exists?("docs/schema/schemata/artist.yaml")
      end
    end
  end

  describe "#url_path" do
    it "builds a URL path" do
      @gen.args = ["endpoint", "resource_history"]
      assert_equal "/resource-histories", @gen.url_path
    end
  end
end
