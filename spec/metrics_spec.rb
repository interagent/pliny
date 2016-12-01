require "spec_helper"

describe Pliny::Metrics do
  subject(:metrics) { Pliny::Metrics }

  let(:test_backend) { double(count: nil, measure: nil) }

  before do
    allow(Config).to receive(:app_name).and_return('pliny')
  end

  after do
    Pliny::Metrics.reset_backend
  end

  it "defaults to the Logger backend" do
    assert_equal Pliny::Metrics.backend, Pliny::Metrics::Backends::Logger
  end

  it "can set a different backend" do
    Pliny::Metrics.backend = test_backend
    assert_equal Pliny::Metrics.backend, test_backend
  end

  describe "#count" do
    before { Pliny::Metrics.backend = test_backend }

    it "delegates to the backend with a default value" do
      metrics.count(:foo)
      expect(test_backend).to have_received(:count).once.with(:foo, value: 1)
    end

    it "delegates to the backend with a provided value" do
      metrics.count(:foo, value: 2)
      expect(test_backend).to have_received(:count).once.with(:foo, value: 2)
    end

    it "delegates multiple key counts to the backend" do
      metrics.count(:foo, :bar)
      expect(test_backend).to have_received(:count).once.with(:foo, :bar, value: 1)
    end
  end

  describe "#measure" do
    before { Pliny::Metrics.backend = test_backend }
    let(:block) { Proc.new {} }

    it "delegates to the backend with a single key" do
      metrics.measure(:foo, &block)
      expect(test_backend).to have_received(:measure).once.with(:foo, &block)
    end

    it "delegates to the backend with multiple keys" do
      metrics.measure(:foo, :bar, &block)
      expect(test_backend).to have_received(:measure).once.with(:foo, :bar, &block)
    end
  end
end
