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

  describe '#uuid_paginator' do
    it 'calls #paginator' do
      resource = Class.new
      stub(resource).count { 12 }
      mock(sinatra).paginator(12, sort_by: :foo)
      sinatra.uuid_paginator(resource, sort_by: :foo)
    end
  end

  describe '#integer_paginator' do
    it 'calls IntegerPaginator.run' do
      mock(Pliny::Helpers::Paginator::IntegerPaginator).run(sinatra, 12, sort_by: :foo)
      sinatra.integer_paginator(12, sort_by: :foo)
    end
  end
end
