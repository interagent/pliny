require 'pliny/commands/generator'
require 'pliny/commands/generator/migration'
require 'spec_helper'

describe Pliny::Commands::Generator::Base do
  subject { Pliny::Commands::Generator::Migration.new(migration_name, {}, StringIO.new) }

  describe '#name' do
    shared_examples 'a migration name' do
      it 'generates a snakecase name' do
        assert_equal 'add_column_foo_to_barz', subject.name
      end
    end

    context 'given array of args' do
      let(:migration_name) { %w(add column foo to barz) }
      it_behaves_like 'a migration name'
    end

    context 'given string separated by whitepsaces' do
      let(:migration_name) { 'add column foo to barz' }
      it_behaves_like 'a migration name'
    end

    context 'given a snakecase name' do
      let(:migration_name) { 'add_column_foo_to_barz' }
      it_behaves_like 'a migration name'
    end

    context 'given a camelcase name' do
      let(:migration_name) { 'AddColumnFooToBarz' }
      it_behaves_like 'a migration name'
    end
  end
end
