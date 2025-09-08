# frozen_string_literal: true

require "pliny/commands/generator"
require "pliny/commands/generator/base"
require "spec_helper"

describe Pliny::Commands::Generator::Base do
  def generator(name, options = {}, stream = StringIO.new)
    Pliny::Commands::Generator::Base.new(name, options, stream)
  end

  describe "#name" do
    it "generates a normalized name given differents argument formats" do
      [
        "resource history",
        "resource-history",
        "resource_history",
        "ResourceHistory"
      ].each do |argument|
        actual = generator(argument).name
        assert_equal "resource_history", actual
      end
    end
  end

  describe "#singular_class_name" do
    it "builds a class name for an endpoint" do
      actual = generator("resource_histories").singular_class_name
      assert_equal "ResourceHistory", actual
    end
  end

  describe "#plural_class_name" do
    it "builds a class name for a model" do
      actual = generator("resource_histories").plural_class_name
      assert_equal "ResourceHistories", actual
    end
  end

  describe "#field_name" do
    it "uses the singular form" do
      actual = generator("resource_histories").field_name
      assert_equal "resource_history", actual
    end
  end

  describe "#pluralized_file_name" do
    it "uses the plural form" do
      actual = generator("resource_history").pluralized_file_name
      assert_equal "resource_histories", actual
    end

    describe "when name with slashs" do
      it "handles slashs as directory" do
        actual = generator("resource/history").pluralized_file_name
        assert_equal "resource/histories", actual
      end
    end
  end

  describe "#table_name" do
    it "uses the plural form" do
      actual = generator("resource_history").table_name
      assert_equal "resource_histories", actual
    end

    describe "when name with slashs" do
      it "handles slashs as underscores" do
        actual = generator("resource/history").table_name
        assert_equal "resource_histories", actual
      end
    end
  end

  describe "#display" do
    it "puts given message into stream" do
      stream = StringIO.new
      message = "Hello world"
      generator("resource_history", {}, stream).display(message)

      assert_includes stream.string, message
    end
  end

  describe "#render_template" do
    it "renders template into a string" do
      template = generator("resource_history").render_template("endpoint.erb")
      assert_match(/module Endpoints/, template)
    end
  end

  describe "#write_template" do
    let(:destination_path) { File.join(Dir.mktmpdir, "endpoint.rb") }

    before do
      generator("resource_history").write_template("endpoint.erb", destination_path)
    end

    it "renders given template into a file by given path" do
      assert File.exist?(destination_path)
      assert_match(/module Endpoints/, File.read(destination_path))
    end
  end

  describe "#write_file" do
    let(:destination_path) { File.join(Dir.mktmpdir, "foo.txt") }

    before do
      generator("resource_history").write_file(destination_path) do
        "Hello world"
      end
    end

    it "creates a file by given path" do
      assert File.exist?(destination_path)
    end

    it "writes given content into a file" do
      assert_match(/Hello world/, File.read(destination_path))
    end
  end
end
