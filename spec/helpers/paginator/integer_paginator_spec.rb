require 'spec_helper'

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
