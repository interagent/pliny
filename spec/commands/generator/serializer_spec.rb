require 'pliny/commands/generator'
require 'pliny/commands/generator/serializer'
require 'spec_helper'

describe Pliny::Commands::Generator::Serializer do
  subject { Pliny::Commands::Generator::Serializer.new('artist', {}, StringIO.new) }

  around do |example|
    Dir.mktmpdir { |dir| Dir.chdir(dir, &example) }
  end

  describe '#run' do
    before do
      subject.run
    end

    it 'creates a new serializer module' do
      assert File.exist?('lib/serializers/artist.rb')
    end

    it 'creates a test' do
      assert File.exist?('spec/serializers/artist_spec.rb')
    end
  end
end
