# frozen_string_literal: true

require "spec_helper"

describe Pliny::Metrics::Backends::Logger do
  let(:io) { double }

  subject(:backend) { Pliny::Metrics::Backends::Logger }

  before do
    @stdout = Pliny.stdout
    Pliny.stdout = io

    allow(io).to receive(:print)
  end

  after do
    Pliny.stdout = @stdout
  end

  context "#count" do
    it "logs a single key with a value" do
      backend.report_counts('app.foo' => 1)
      expect(io).to have_received(:print).with("count#app.foo=1\n")
    end

    it "logs multiple keys with values" do
      backend.report_counts('app.foo' => 1, 'app.bar' => 2)
      expect(io).to have_received(:print).with(
        "count#app.foo=1 count#app.bar=2\n",
      )
    end
  end

  context "#measure" do
    it "logs a single key with a value" do
      backend.report_measures('pliny.foo' => 0.001)
      expect(io).to have_received(:print).with("measure#pliny.foo=0.001\n")
    end

    it "logs multiple keys with values" do
      backend.report_measures('pliny.foo' => 0.3, 'pliny.bar' => 0.5)
      expect(io).to have_received(:print).with(
        "measure#pliny.foo=0.300 measure#pliny.bar=0.500\n",
      )
    end
  end
end
