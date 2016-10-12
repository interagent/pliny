require "spec_helper"

describe Pliny::Metrics do
  let(:io) { double }

  subject(:metrics) { Pliny::Metrics }

  before do
    @stdout = Pliny.stdout
    Pliny.stdout = io

    allow(io).to receive(:print)
    allow(Config).to receive(:app_name).and_return('pliny')
  end

  after do
    Pliny.stdout = @stdout
  end

  context "#count" do
    it "counts a single key with a default value" do
      metrics.count(:foo)
      expect(io).to have_received(:print).with("count#pliny.foo=1\n")
    end

    it "counts a single key with a provided value" do
      metrics.count(:foo, value: 2)
      expect(io).to have_received(:print).with("count#pliny.foo=2\n")
    end

    it "counts multiple keys" do
      metrics.count(:foo, :bar)
      expect(io).to have_received(:print).with(
        "count#pliny.foo=1 count#pliny.bar=1\n")
    end
  end

  context "#measure" do
    before do
      Timecop.freeze(Time.now)
    end

    it "measures a single key" do
      metrics.measure(:foo) { }
      expect(io).to have_received(:print).with("measure#pliny.foo=0.000\n")
    end

    it "measures a single key over a minute" do
      metrics.measure(:foo) do
        Timecop.travel(60)
      end
      expect(io).to have_received(:print).with("measure#pliny.foo=60.000\n")
    end

    it "measures multiple keys" do
      metrics.measure(:foo, :bar) { }
      expect(io).to have_received(:print).with(
        "measure#pliny.foo=0.000 measure#pliny.bar=0.000\n")
    end
  end
end
