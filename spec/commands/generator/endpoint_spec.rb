require 'pliny/commands/generator'
require 'pliny/commands/generator/endpoint'
require 'spec_helper'

describe Pliny::Commands::Generator::Endpoint do
  subject { Pliny::Commands::Generator::Endpoint.new(model_name, {}, StringIO.new) }

  describe '#url_path' do
    let(:model_name) { 'resource_history' }

    it 'builds a URL path' do
      assert_equal '/resource-histories', subject.url_path
    end
  end
end
