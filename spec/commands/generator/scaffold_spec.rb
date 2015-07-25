require 'pliny/commands/generator/scaffold'
require 'spec_helper'

describe Pliny::Commands::Generator::Scaffold do
  subject do
    Pliny::Commands::Generator::Scaffold
      .new(scaffold_name, scaffold_options, StringIO.new)
  end

  let(:scaffold_name) { 'artist' }
  let(:scaffold_options) { {} }

  describe '#run' do
    it 'runs all generators' do
      %w(
        Endpoint
        Mediator
        Migration
        Model
        Schema
        Serializer
      ).each do |generator_name|
        generator = Pliny::Commands::Generator.const_get(generator_name)
        mock.proxy(generator).new(scaffold_name, scaffold_options) do |instance|
          mock(instance).run
        end
      end

      subject.run
    end
  end
end
