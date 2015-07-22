require 'pliny/commands/generator'
require 'pliny/commands/generator/base'
require 'spec_helper'

describe Pliny::Commands::Generator::Base do
  def generator(name, options = {}, stream = StringIO.new)
    Pliny::Commands::Generator::Base.new(name, options, stream)
  end

  describe '#name' do
    it 'generates a normalized name given differents argument formats' do
      [
        'resource history',
        'resource-history',
        'resource_history',
        'ResourceHistory'
      ].each do |argument|
        actual = generator(argument).name
        assert_equal 'resource_history', actual
      end
    end
  end

  describe '#singular_class_name' do
    it 'builds a class name for an endpoint' do
      actual = generator('resource_histories').singular_class_name
      assert_equal 'ResourceHistory', actual
    end
  end

  describe '#plural_class_name' do
    it 'builds a class name for a model' do
      actual = generator('resource_histories').plural_class_name
      assert_equal 'ResourceHistories', actual
    end
  end

  describe '#field_name' do
    it 'uses the singular form' do
      actual = generator('resource_histories').field_name
      assert_equal 'resource_history', actual
    end
  end

  describe '#pluralized_file_name' do
    it 'uses the plural form' do
      actual = generator('resource_history').pluralized_file_name
      assert_equal 'resource_histories', actual
    end

    describe 'when name with slashs' do
      it 'handles slashs as directory' do
        actual = generator('resource/history').pluralized_file_name
        assert_equal 'resource/histories', actual
      end
    end
  end

  describe '#table_name' do
    it 'uses the plural form' do
      actual = generator('resource_history').table_name
      assert_equal 'resource_histories', actual
    end

    describe 'when name with slashs' do
      it 'handles slashs as underscores' do
        actual = generator('resource/history').table_name
        assert_equal 'resource_histories', actual
      end
    end
  end
end
