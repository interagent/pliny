require 'pliny/helpers/paginator'
require 'test_helper'

describe Pliny::Helpers::Paginator do
  let(:dummy_class) { Class.new { include Pliny::Helpers::Paginator } }
  let(:sinatra) { dummy_class.new }

  it 'calls Pagiantor.run' do
    mock(Pliny::Helpers::Paginator::Paginator).run(sinatra, 12, sort_by: :foo)
    sinatra.paginator(12, sort_by: :foo)
  end
end

describe Pliny::Helpers::Paginator::Paginator do
  subject { Pliny::Helpers::Paginator::Paginator.new(sinatra, count, opts) }
  let(:dummy_class) { Class.new { include Pliny::Helpers::Paginator } }
  let(:sinatra) { dummy_class.new }
  let(:count) { 4 }
  let(:opts) { {} }

  describe '#run' do
    it 'returns Hash' do
      mock(subject).validate_options
      mock(subject).set_headers
      stub(subject).res { { args: {} } }

      assert_kind_of Hash, subject.run
    end
  end

  describe '#request_options' do
    it 'returns Hash' do
      stub(sinatra).request do |klass|
        stub(klass).env { { 'Range' => 'id 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=200' } }
      end
      assert_kind_of Hash, subject.request_options
    end

    describe 'when Range is nil' do
      it 'returns empty Hash' do
        stub(sinatra).request do |klass|
          stub(klass).env { {} }
        end
        assert_kind_of Hash, subject.request_options
        assert_empty subject.request_options
      end
    end

    describe 'when Range is an empty string' do
      it 'returns empty Hash' do
        stub(sinatra).request do |klass|
          stub(klass).env { { 'Range' => '' } }
        end
        assert_kind_of Hash, subject.request_options
        assert_empty subject.request_options
      end
    end

    describe 'when Range is an invalid string' do
      it 'halts' do
        stub(sinatra).request do |klass|
          stub(klass).env { { 'Range' => 'foo' } }
        end
        mock(subject).halt
        subject.request_options
      end
    end

    describe 'when Range is valid' do
      describe 'without args' do
        it 'returns Hash' do
          stub(sinatra).request do |klass|
            stub(klass).env { { 'Range' => 'id 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef' } }
          end
          result =
            {
              sort_by: 'id',
              first: '01234567-89ab-cdef-0123-456789abcdef',
              last: '01234567-89ab-cdef-0123-456789abcdef'
            }
          assert_equal subject.request_options, result
        end
      end

      describe 'with one arg' do
        it 'returns Hash' do
          stub(sinatra).request do |klass|
            stub(klass).env { { 'Range' => 'id 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=200' } }
          end
          result =
            {
              sort_by: 'id',
              first: '01234567-89ab-cdef-0123-456789abcdef',
              last: '01234567-89ab-cdef-0123-456789abcdef',
              args: { max: '200' }
            }
          assert_equal subject.request_options, result
        end
      end

      describe 'with more args' do
        it 'returns Hash' do
          stub(sinatra).request do |klass|
            stub(klass).env { { 'Range' => 'id 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=200,order=desc' } }
          end
          result =
            {
              sort_by: 'id',
              first: '01234567-89ab-cdef-0123-456789abcdef',
              last: '01234567-89ab-cdef-0123-456789abcdef',
              args: { max: '200', order: 'desc' }
            }
          assert_equal subject.request_options, result
        end
      end
    end
  end
end
