# frozen_string_literal: true

require 'pliny/commands/generator/model'
require 'spec_helper'

describe Pliny::Commands::Generator::Model do
  subject { described_class.new('artist', {}, StringIO.new) }

  around do |example|
    Dir.chdir(Dir.mktmpdir, &example)
  end

  describe '#create' do
    it 'creates a model file' do
      subject.create
      assert File.exist?('lib/models/artist.rb')
    end
  end

  describe '#create_migration' do
    it 'creates a migration file' do
      subject.create_migration
      assert_equal 1, Dir.glob("db/migrate/*_create_artists.rb").size
    end
  end

  describe '#create_test' do
    it 'creates a model test file' do
      subject.create_test
      assert File.exist?('spec/models/artist_spec.rb')
    end
  end
end
