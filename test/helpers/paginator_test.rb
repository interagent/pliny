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
      stub(subject).options { { args: {} } }

      assert_kind_of Hash, subject.run
    end

    it 'evaluates block' do
      mock(subject).validate_options
      mock(subject).set_headers
      subject.instance_variable_set(:@options, args: { max: 200 })

      result =
        subject.run do |paginator|
          paginator[:first] = 42
        end

      assert_equal 42, result[:first]
    end
  end

  describe '#request_options' do
    it 'returns Hash' do
      stub(sinatra).request do |klass|
        stub(klass).env { { 'Range' => 'id 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=1000' } }
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
      describe 'with first only' do
        it 'returns Hash' do
          stub(sinatra).request do |klass|
            stub(klass).env { { 'Range' => 'id 01234567-89ab-cdef-0123-456789abcdef' } }
          end
          result =
            {
              sort_by: 'id',
              first: '01234567-89ab-cdef-0123-456789abcdef'
            }
          assert_equal result, subject.request_options
        end
      end

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
          assert_equal result, subject.request_options
        end

        describe 'with count' do
          it 'returns Hash' do
            stub(sinatra).request do |klass|
              stub(klass).env { { 'Range' => 'id 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef/400' } }
            end
            result =
              {
                sort_by: 'id',
                first: '01234567-89ab-cdef-0123-456789abcdef',
                last: '01234567-89ab-cdef-0123-456789abcdef'
              }
            assert_equal result, subject.request_options
          end
        end
      end

      describe 'with one arg' do
        it 'returns Hash' do
          stub(sinatra).request do |klass|
            stub(klass).env { { 'Range' => 'id 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=1000' } }
          end
          result =
            {
              sort_by: 'id',
              first: '01234567-89ab-cdef-0123-456789abcdef',
              last: '01234567-89ab-cdef-0123-456789abcdef',
              args: { max: '1000' }
            }
          assert_equal result, subject.request_options
        end

        describe 'with count' do
          it 'returns Hash' do
            stub(sinatra).request do |klass|
              stub(klass).env { { 'Range' => 'id 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef/400; max=1000' } }
            end
            result =
              {
                sort_by: 'id',
                first: '01234567-89ab-cdef-0123-456789abcdef',
                last: '01234567-89ab-cdef-0123-456789abcdef',
                args: { max: '1000' }
              }
            assert_equal result, subject.request_options
          end
        end
      end

      describe 'with more args' do
        it 'returns Hash' do
          stub(sinatra).request do |klass|
            stub(klass).env { { 'Range' => 'id 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=1000,order=desc' } }
          end
          result =
            {
              sort_by: 'id',
              first: '01234567-89ab-cdef-0123-456789abcdef',
              last: '01234567-89ab-cdef-0123-456789abcdef',
              args: { max: '1000', order: 'desc' }
            }
          assert_equal result, subject.request_options
        end

        describe 'with count' do
          it 'returns Hash' do
            stub(sinatra).request do |klass|
              stub(klass).env { { 'Range' => 'id 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef/400; max=1000,order=desc' } }
            end
            result =
              {
                sort_by: 'id',
                first: '01234567-89ab-cdef-0123-456789abcdef',
                last: '01234567-89ab-cdef-0123-456789abcdef',
                args: { max: '1000', order: 'desc' }
              }
            assert_equal result, subject.request_options
          end
        end
      end
    end
  end

  describe '#build_range' do
    it 'only sort_by' do
      assert_equal 'id',
                   subject.build_range(:id, nil, nil, nil)
    end

    it 'only sort_by, first' do
      assert_equal 'id 100',
                   subject.build_range(:id, 100, nil, nil)
    end

    it 'only sort_by, first, last' do
      assert_equal 'id 100..200',
                   subject.build_range(:id, 100, 200, nil)
    end

    it 'only sort_by, last' do
      assert_equal 'id',
                   subject.build_range(:id, nil, 200, nil)
    end

    it 'only sort_by, first, args' do
      assert_equal 'id 100; max=300,order=desc',
                   subject.build_range(:id, 100, nil, max: 300, order: 'desc')
    end

    it 'only sort_by, first, last, args' do
      assert_equal 'id 100..200; max=300,order=desc',
                   subject.build_range(:id, 100, 200, max: 300, order: 'desc')
    end

    it 'only sort_by, first, count' do
      assert_equal 'id 100/1200',
                   subject.build_range(:id, 100, nil, nil, 1200)
    end

    it 'only sort_by, first, last, count' do
      assert_equal 'id 100..200/1200',
                   subject.build_range(:id, 100, 200, nil, 1200)
    end

    it 'only sort_by, first, args, count' do
      assert_equal 'id 100/1200; max=300,order=desc',
                   subject.build_range(:id, 100, nil, { max: 300, order: 'desc' }, 1200)
    end
  end

  describe '#will_paginate?' do
    it 'converts max to integer' do
      subject.instance_variable_set(:@options, args: { max: '1000' })
      stub(subject).count { 2000 }
      assert subject.will_paginate?
    end
  end

  describe '#[]' do
    describe 'allows to read #options with a convenience method' do
      before :each do
        mock(subject).options { { first: 1 } }
      end

      it 'with symbol key' do
        assert_equal subject[:first], 1
      end

      it 'with string key' do
        assert_equal subject['first'], 1
      end
    end
  end

  describe '#[]=' do
    describe 'allows to read #options with a convenience method' do
      before :each do
        subject.instance_variable_set(:@options, {})
      end

      it 'with symbol key' do
        assert_equal nil, subject.options[:first]
        subject[:first] = 1
        assert_equal 1, subject.options[:first]
      end

      it 'with string key' do
        assert_equal nil, subject.options[:first]
        subject['first'] = 1
        assert_equal 1, subject.options[:first]
      end
    end
  end
end
