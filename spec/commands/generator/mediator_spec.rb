require 'pliny/commands/generator'
require 'pliny/commands/generator/mediator'
require 'spec_helper'

describe Pliny::Commands::Generator::Mediator do
  subject { Pliny::Commands::Generator::Mediator.new('artists/creator', {}, StringIO.new) }

  around do |example|
    Dir.mktmpdir { |dir| Dir.chdir(dir, &example) }
  end

  describe '#run' do
    before do
      subject.run
    end

    it 'creates a new mediator module' do
      assert File.exist?('lib/mediators/artists/creator.rb')
    end

    it 'creates a test' do
      assert File.exist?('spec/mediators/artists/creator_spec.rb')
    end
  end
end
