require 'pliny/commands/creator'
require 'pliny/commands/generator'
require 'pliny/commands/generator/schema'
require 'spec_helper'

describe Pliny::Commands::Generator::Schema do
  let(:stream) { StringIO.new }
  subject { Pliny::Commands::Generator::Schema.new('artist', {}, stream) }

  around do |example|
    Dir.mktmpdir do |dir|
      app_dir = File.join(dir, "app")
      # schema work depends on files seeded by the template
      Pliny::Commands::Creator.run([app_dir], {}, StringIO.new)

      # create a variant for the purposes of the tests
      FileUtils.mkdir_p("#{app_dir}/schema/variants/my_variant/schemata")
      File.open("#{app_dir}/schema/variants/my_variant/schemata/test.json", 'w') do |f|
        f.write({
          id: "schemata/my_variant"
        }.to_json)
      end

      Dir.chdir(app_dir, &example)
    end
  end


  describe '#create' do
    context 'with new layout' do
      before do
        subject.create
      end

      it 'creates a schema' do
        assert File.exist?('schema/schemata/artist.yaml')
      end
    end

    context 'with legacy layout' do
      before do
        FileUtils.mkdir_p('./docs/schema/schemata')
        FileUtils.cp('./schema/meta.json', './docs/schema')
        subject.create
      end

      it 'creates a legacy schema' do
        assert File.exist?('docs/schema/schemata/artist.yaml')
      end

      it 'warns' do
        assert_match(/WARNING/m, stream.string)
      end
    end
  end

  describe '#rebuild' do
    context 'with nil as the name argument (as used in schema.rake)' do
      it 'rebuilds the schema with prmd' do
        assert_output("rebuilt ./schema/schema.json\nrebuilt ./schema/variants/my_variant/schema.json\n") do
          Pliny::Commands::Generator::Schema.new(nil).rebuild
        end
      end
    end

    context 'with new layout' do
      before do
        subject.rebuild
      end

      it 'rebuilds schema.json' do
        assert File.exist?('./schema/schema.json')
      end
    end

    context 'with legacy layout' do
      before do
        FileUtils.mkdir_p('./docs/schema/schemata')
        FileUtils.cp('./schema/meta.json', './docs/schema')
        subject.rebuild
      end

      it 'rebuilds legacy schema.json' do
        assert File.exist?('docs/schema.json')
      end

      it 'warns' do
        assert_match(/WARNING/m, stream.string)
      end
    end
  end
end
