require 'pliny/commands/generator/serializer'
require 'spec_helper'

describe Pliny::Commands::Generator::Serializer do
  subject { described_class.new('artist', {}, StringIO.new) }

  around do |example|
    Dir.chdir(Dir.mktmpdir, &example)
  end

  describe '#create' do
    it 'creates a serializer file' do
      subject.create
      assert File.exist?('lib/serializers/artist.rb')
    end
  end

  describe '#create_test' do
    it 'creates a serializer test file' do
      subject.create_test
      assert File.exist?('spec/serializers/artist_spec.rb')
    end
  end
end
