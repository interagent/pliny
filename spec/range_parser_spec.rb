require "spec_helper"

describe Pliny::RangeParser do
  subject(:parser) { described_class.new(range_header) }

  context 'with a bound range' do
    let(:range_header) { 'objects 0-99' }

    it 'parses a start and an end' do
      assert_equal 0, parser.start
      assert_equal 99, parser.end
    end
  end

  context 'with an unbound range' do
    let(:range_header) { 'objects 0-' }

    it 'parses a start' do
      assert_equal 0, parser.start
      assert_nil parser.end
    end
  end

  context 'with parameters' do
    let(:range_header) { 'objects 0-99; a=b, c=d' }

    it 'parses parameters' do
      assert_equal({ a: 'b', c: 'd' }, parser.parameters)
    end
  end
end
