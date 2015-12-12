require "spec_helper"

describe Pliny::RangeParser do
  subject(:parser) { described_class.new(range_header) }

  context 'with an empty header' do
    let(:range_header) { nil }

    it 'parses' do
      assert_nil parser.start
      assert_nil parser.end
      assert_equal({}, parser.parameters)
    end
  end

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

  context 'with multiple semicolons' do
    let(:range_header) { 'objects 0-99; a=b; c=d' }
    let(:message) { Pliny::RangeParser::RANGE_FORMAT_ERROR }

    it 'raises a bad request' do
      assert_raises Pliny::Errors::BadRequest, message do
        parser
      end
    end
  end

  context 'with a non objects unit' do
    let(:range_header) { 'ids 0-99' }
    let(:message) { Pliny::RangeParser::RANGE_FORMAT_ERROR }

    it 'raises a bad request' do
      assert_raises Pliny::Errors::BadRequest, message do
        parser
      end
    end
  end
end
