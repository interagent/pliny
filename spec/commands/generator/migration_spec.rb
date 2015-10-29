require 'pliny/commands/generator/migration'
require 'spec_helper'

describe Pliny::Commands::Generator::Migration do
  subject { described_class.new('create_artists', {}, StringIO.new) }

  around do |example|
    Dir.chdir(Dir.mktmpdir, &example)
  end

  describe '#create' do
    it 'creates a migration file' do
      subject.create
      assert_equal 1, Dir.glob("db/migrate/*_create_artists.rb").size
    end
  end
end
