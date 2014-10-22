require 'pliny/commands/generator'
require 'pliny/commands/generator/base'
require 'spec_helper'

describe Pliny::Commands::Generator::Base do
  subject { Pliny::Commands::Generator::Base.new(model_name, {}, StringIO.new) }

  describe '#singular_class_name' do
    let(:model_name) { 'resource_histories' }

    it 'builds a class name for an endpoint' do
      assert_equal 'ResourceHistory', subject.singular_class_name
    end

    describe 'when name with hypens' do
      let(:model_name) { 'resource-histories' }

      it 'handles hyphens as underscores' do
        assert_equal 'ResourceHistory', subject.singular_class_name
      end
    end
  end

  describe '#plural_class_name' do
    let(:model_name) { 'resource_histories' }

    it 'builds a class name for a model' do
      assert_equal 'ResourceHistories', subject.plural_class_name
    end

    describe 'when name with hypens' do
      let(:model_name) { 'resource-histories' }

      it 'handles hyphens as underscores' do
        assert_equal 'ResourceHistories', subject.plural_class_name
      end
    end
  end

  describe '#field_name' do
    let(:model_name) { 'resource_histories' }

    it 'uses the singular form' do
      assert_equal 'resource_history', subject.field_name
    end

    describe 'when name with hypens' do
      let(:model_name) { 'resource-histories' }

      it 'handles hyphens as underscores' do
        assert_equal 'resource_history', subject.field_name
      end
    end
  end

  describe '#pluralized_file_name' do
    let(:model_name) { 'resource_history' }

    it 'uses the plural form' do
      assert_equal 'resource_histories', subject.pluralized_file_name
    end

    describe 'when name with hypens' do
      let(:model_name) { 'resource-history' }

      it 'handles hyphens as underscores' do
        assert_equal 'resource_histories', subject.pluralized_file_name
      end
    end

    describe 'when name with slashs' do
      let(:model_name) { 'resource/history' }

      it 'handles slashs as directory' do
        assert_equal 'resource/histories', subject.pluralized_file_name
      end
    end
  end

  describe '#table_name' do
    let(:model_name) { 'resource_history' }

    it 'uses the plural form' do
      assert_equal 'resource_histories', subject.table_name
    end

    describe 'when name with hypens' do
      let(:model_name) { 'resource-history' }

      it 'handles hyphens as underscores' do
        assert_equal 'resource_histories', subject.table_name
      end
    end

    describe 'when name with slashs' do
      let(:model_name) { 'resource/history' }

      it 'handles slashs as underscores' do
        assert_equal 'resource_histories', subject.table_name
      end
    end
  end
end
