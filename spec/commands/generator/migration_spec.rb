require 'pliny/commands/generator'
require 'pliny/commands/generator/migration'
require 'spec_helper'

describe Pliny::Commands::Generator::Migration do
  describe '#name' do
    it 'generates a migration name given differents argument formats' do
      [
        %w(add column foo to barz),
        'add column foo to barz',
        'add_column_foo_to_barz',
        'AddColumnFooToBarz'
      ].each do |argument|
        actual = described_class.new(argument, {}, StringIO.new).name
        assert_equal 'add_column_foo_to_barz', actual
      end
    end
  end
end
