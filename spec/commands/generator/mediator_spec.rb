require 'pliny/commands/generator/mediator'
require 'spec_helper'

describe Pliny::Commands::Generator::Mediator do
  subject { described_class.new('creator', {}, StringIO.new) }

  around do |example|
    Dir.chdir(Dir.mktmpdir, &example)
  end

  describe '#create' do
    it 'creates a mediator file' do
      subject.create
      assert File.exist?('lib/mediators/creator.rb')
    end
  end

  describe '#create_test' do
    it 'creates a mediator test file' do
      subject.create_test
      assert File.exist?('spec/mediators/creator_spec.rb')
    end
  end
end
