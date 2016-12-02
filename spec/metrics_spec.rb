require "spec_helper"

describe Pliny::Metrics do
  subject(:metrics) { Pliny::Metrics }

  let(:test_backend) { double(report_counts: nil, report_measures: nil) }

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

    it "sends a hash to the backend with a default value" do
      metrics.count(:foo)
      expect(test_backend).to have_received(:report_counts).once.with("pliny.foo" => 1)
    end

    it "sends a hash to the backend with a provided value" do
      metrics.count(:foo, value: 2)
      expect(test_backend).to have_received(:report_counts).once.with("pliny.foo" => 2)
    end

    it "sends a hash with multiple key counts to the backend" do
      metrics.count(:foo, :bar)
      expect(test_backend).to have_received(:report_counts).once.with(
        "pliny.foo" => 1,
        "pliny.bar" => 1
      )
    end
  end

  describe "#measure" do
    before { Pliny::Metrics.backend = test_backend }
    let(:block) { Proc.new {} }
    before do
      Timecop.freeze(Time.now)
    end

    it "measures a single key" do
      metrics.measure(:foo, &block)
      expect(test_backend).to have_received(:report_measures).once.with(
        "pliny.foo" => 0
      )
    end

    it "measures a single key over a minute" do
      metrics.measure(:foo) do
        Timecop.travel(60)
      end

      expect(test_backend).to have_received(:report_measures) do |opts|
        assert(60 <= opts['pliny.foo'] && opts['pliny.foo'] <= 61)
      end
    end

    it "measures multiple keys" do
      metrics.measure(:foo, :bar) { }
      expect(test_backend).to have_received(:report_measures).once.with(
        "pliny.foo" => 0,
        "pliny.bar" => 0
      )
    end
  end
end
