require 'test_helper'

describe Pliny::Helpers::Paginator do
  let(:dummy_class) { Class.new { include Pliny::Helpers::Paginator } }
  let(:sinatra) { dummy_class.new }

  describe '#paginator' do
    it 'calls Pagiantor.run' do
      mock(Pliny::Helpers::Paginator::Paginator).run(sinatra, 12, sort_by: :foo)
      sinatra.paginator(12, sort_by: :foo)
    end
  end

  describe '#integer_paginator' do
    it 'calls IntegerPaginator.run' do
      mock(Pliny::Helpers::Paginator::IntegerPaginator).run(sinatra, 12, sort_by: :foo)
      sinatra.integer_paginator(12, sort_by: :foo)
    end
  end
end

describe Pliny::Helpers::Paginator::Paginator do
  subject { Pliny::Helpers::Paginator::Paginator.new(sinatra, count, opts) }
  let(:dummy_class) { Class.new { include Pliny::Helpers::Paginator } }
  let(:sinatra) { dummy_class.new }
  let(:count) { 4 }
  let(:opts) { {} }

  describe '#run' do
    it 'evaluates block' do
      mock(subject).validate_options
      mock(subject).set_headers
      subject.instance_variable_set(:@options, args: { max: 200 })

      result =
        subject.run do |paginator|
          paginator[:first] = 42
        end

      assert_equal 42, result
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

    describe 'when Range is valid' do
      before :each do
        stub(sinatra).request do |klass|
          stub(klass).env do
            { 'Range' => range }
          end
        end
      end

      describe 'UUID' do
        describe 'only sort_by' do
          let(:range) { 'id' }

          it 'returns Hash' do
            result =
              {
                sort_by: 'id'
              }
            assert_equal result, subject.request_options
          end
        end

        describe 'only sort_by, first' do
          let(:range) { 'id 01234567-89ab-cdef-0123-456789abcdef' }

          it 'returns Hash' do
            result =
              {
                sort_by: 'id',
                first: '01234567-89ab-cdef-0123-456789abcdef'
              }
            assert_equal result, subject.request_options
          end
        end

        describe 'only sort_by, args' do
          let(:range) { 'id; max=1000' }

          it 'returns Hash' do
            result =
              {
                sort_by: 'id',
                args: { max: '1000' }
              }
            assert_equal result, subject.request_options
          end
        end

        describe 'only sort_by, count' do
          let(:range) { 'id/400' }

          it 'returns Hash' do
            result =
              {
                sort_by: 'id'
              }
            assert_equal result, subject.request_options
          end
        end

        describe 'only sort_by, first, last' do
          let(:range) { 'id 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef' }

          it 'returns Hash' do
            result =
              {
                sort_by: 'id',
                first: '01234567-89ab-cdef-0123-456789abcdef',
                last: '01234567-89ab-cdef-0123-456789abcdef'
              }
            assert_equal result, subject.request_options
          end
        end

        describe 'only sort_by, first, args' do
          let(:range) { 'id 01234567-89ab-cdef-0123-456789abcdef; max=1000' }

          it 'returns Hash' do
            result =
              {
                sort_by: 'id',
                first: '01234567-89ab-cdef-0123-456789abcdef',
                args: { max: '1000' }
              }
            assert_equal result, subject.request_options
          end
        end

        describe 'only sort_by, first, count' do
          let(:range) { 'id 01234567-89ab-cdef-0123-456789abcdef/400' }

          it 'returns Hash' do
            result =
              {
                sort_by: 'id',
                first: '01234567-89ab-cdef-0123-456789abcdef'
              }
            assert_equal result, subject.request_options
          end
        end

        describe 'only sort_by, first, last, args' do
          describe 'one arg' do
            let(:range) { 'id 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=1000' }

            it 'returns Hash' do
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

          describe 'more args' do
            let(:range) { 'id 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=1000,order=desc' }

            it 'returns Hash' do
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

        describe 'only sort_by, first, last, args, count' do
          describe 'one arg' do
            let(:range) { 'id 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef/400; max=1000' }

            it 'returns Hash' do
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

          describe 'more args' do
            let(:range) { 'id 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef/400; max=1000,order=desc' }

            it 'returns Hash' do
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

        describe 'only sort_by, first, last, count' do
          let(:range) { 'id 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef/400' }

          it 'returns Hash' do
            result =
              {
                sort_by: 'id',
                first: '01234567-89ab-cdef-0123-456789abcdef',
                last: '01234567-89ab-cdef-0123-456789abcdef'
              }
            assert_equal result, subject.request_options
          end
        end

        describe 'only sort_by, first, args, count' do
          let(:range) { 'id 01234567-89ab-cdef-0123-456789abcdef/400; max=1000,order=desc' }

          it 'returns Hash' do
            result =
              {
                sort_by: 'id',
                first: '01234567-89ab-cdef-0123-456789abcdef',
                args: { max: '1000', order: 'desc' }
              }
            assert_equal result, subject.request_options
          end
        end

        describe 'only sort_by, args' do
          let(:range) { 'id; max=1000,order=desc' }

          it 'returns Hash' do
            result =
              {
                sort_by: 'id',
                args: { max: '1000', order: 'desc' }
              }
            assert_equal result, subject.request_options
          end
        end

        describe 'only sort_by, args, count' do
          let(:range) { 'id/400; max=1000,order=desc' }

          it 'returns Hash' do
            result =
              {
                sort_by: 'id',
                args: { max: '1000', order: 'desc' }
              }
            assert_equal result, subject.request_options
          end
        end

        describe 'only sort_by, count' do
          let(:range) { 'id/400' }

          it 'returns Hash' do
            result =
              {
                sort_by: 'id'
              }
            assert_equal result, subject.request_options
          end
        end
      end

      describe 'timestamp in iso8601' do
        let(:range) { "#{sort_by} #{first}..#{last}/400; max=1000,order=desc" }
        let(:sort_by) { 'created_at' }
        let(:first) { '1985-09-24T00:00:00+00:00' }
        let(:last) { '2014-07-01T15:54:32+02:00' }

        it 'returns Hash' do
          result =
            {
              sort_by: sort_by,
              first: first,
              last: last,
              args: { max: '1000', order: 'desc' }
            }
          assert_equal result, subject.request_options
        end
      end

      describe 'fruits' do
        let(:range) { "#{sort_by} #{first}..#{last}/400; max=1000,order=desc" }
        let(:sort_by) { 'fruit' }
        let(:first) { 'Apple' }
        let(:last) { 'Banana' }

        it 'returns Hash' do
          result =
            {
              sort_by: sort_by,
              first: first,
              last: last,
              args: { max: '1000', order: 'desc' }
            }
          assert_equal result, subject.request_options
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

    it 'only sort_by, last' do
      assert_equal 'id',
                   subject.build_range(:id, nil, 200, nil)
    end

    it 'only sort_by, args' do
      assert_equal 'id; max=300,order=desc',
                   subject.build_range(:id, nil, nil, max: 300, order: 'desc')
    end

    it 'only sort_by, count' do
      assert_equal 'id/1200',
                   subject.build_range(:id, nil, nil, nil, 1200)
    end

    it 'only sort_by, first, last' do
      assert_equal 'id 100..200',
                   subject.build_range(:id, 100, 200, nil)
    end

    it 'only sort_by, first, args' do
      assert_equal 'id 100; max=300,order=desc',
                   subject.build_range(:id, 100, nil, max: 300, order: 'desc')
    end

    it 'only sort_by, first, count' do
      assert_equal 'id 100/1200',
                   subject.build_range(:id, 100, nil, nil, 1200)
    end

    it 'only sort_by, first, last, args' do
      assert_equal 'id 100..200; max=300,order=desc',
                   subject.build_range(:id, 100, 200, max: 300, order: 'desc')
    end

    it 'only sort_by, first, last, count' do
      assert_equal 'id 100..200/1200',
                   subject.build_range(:id, 100, 200, nil, 1200)
    end

    it 'only sort_by, first, args, count' do
      assert_equal 'id 100/1200; max=300,order=desc',
                   subject.build_range(:id, 100, nil, { max: 300, order: 'desc' }, 1200)
    end

    it 'only sort_by, args' do
      assert_equal 'id; max=300,order=desc',
                   subject.build_range(:id, nil, nil, max: 300, order: 'desc')
    end

    it 'only sort_by, args, count' do
      assert_equal 'id/1200; max=300,order=desc',
                   subject.build_range(:id, nil, nil, { max: 300, order: 'desc' }, 1200)
    end

    it 'only sort_by, count' do
      assert_equal 'id/1200',
                   subject.build_range(:id, nil, nil, nil, 1200)
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

describe Pliny::Helpers::Paginator::IntegerPaginator do
  subject { Pliny::Helpers::Paginator::IntegerPaginator.new(sinatra, count, opts) }
  let(:dummy_class) { Class.new { include Pliny::Helpers::Paginator } }
  let(:sinatra) { dummy_class.new }
  let(:count) { 4 }
  let(:opts) { {} }

  before :each do
    any_instance_of(Pliny::Helpers::Paginator::Paginator) do |klass|
      stub(klass).request_options { {} }
      stub(klass).set_headers
    end
  end

  describe '#run' do
    it 'returns Hash' do
      result = subject.run

      assert_kind_of Hash, result

      exp =
        {
          order_by: :id,
          offset: nil,
          limit: 200
        }

      assert_equal exp, result
    end
  end

  describe '#calculate_pages' do
    let(:opts) { { first: 100, args: { max: 300 } } }

    describe 'when count < max in current range' do
      let(:count) { 200 }

      it 'calculates :last' do
        assert_equal 199, subject.calculate_pages[:last]
      end

      it 'calculates :next_first' do
        assert_equal nil, subject.calculate_pages[:next_first]
      end

      it 'calculates :next_last' do
        assert_equal nil, subject.calculate_pages[:next_last]
      end
    end

    describe 'when count > max in current range' do
      let(:count) { 3000 }

      it 'calculates :last' do
        assert_equal 399, subject.calculate_pages[:last]
      end

      it 'calculates :next_first' do
        assert_equal 400, subject.calculate_pages[:next_first]
      end

      describe 'when count < max in next range' do
        let(:count) { 600 }

        it 'calculates :next_last' do
          assert_equal 599, subject.calculate_pages[:next_last]
        end
      end

      describe 'when count > max in next range' do
        let(:count) { 3000 }

        it 'calculates :next_last' do
          assert_equal 699, subject.calculate_pages[:next_last]
        end
      end
    end
  end
end
