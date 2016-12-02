require "spec_helper"
require_relative "../../../lib/pliny/metrics/backends/librato"

describe Pliny::Metrics::Backends::Librato do
  subject(:backend) { described_class.new }

  describe "#report_counts" do
    let(:async_reporter) { double(_report_counts: true) }
    it "delegates to async._report_counts" do
      expect(backend).to receive(:async).and_return(async_reporter)
      expect(async_reporter).to receive(:_report_counts).once.with(
        'pliny.foo' => 1
      )

      backend.report_counts('pliny.foo' => 1)
    end
  end

  describe "#async._report_counts" do
    it "reports a single count to librato" do
      expect(Librato::Metrics).to receive(:submit).with(
        counters: [
          { name: 'pliny.foo', value: 1 }
        ]
      )

      backend.await._report_counts('pliny.foo' => 1)
    end

    it "reports multiple counts to librato" do
      expect(Librato::Metrics).to receive(:submit).with(
        counters: [
          { name: 'pliny.foo', value: 1 },
          { name: 'pliny.bar', value: 2 }
        ]
      )

      backend.await._report_counts('pliny.foo' => 1, 'pliny.bar' => 2)
    end
  end

  describe "#report_measures" do
    let(:async_reporter) { double(_report_measures: true) }

    it "delegates to async._report_measures" do
      expect(backend).to receive(:async).and_return(async_reporter)
      expect(async_reporter).to receive(:_report_measures).once.with(
        'pliny.foo' => 1.002
      )

      backend.report_measures('pliny.foo' => 1.002)
    end
  end

  describe "#async._report_measures" do
    it "reports a single measure to librato" do
      expect(Librato::Metrics).to receive(:submit).with(
        gauges: [
          { name: 'pliny.foo', value: 1.002 }
        ]
      )

      backend.await._report_measures('pliny.foo' => 1.002)
    end

    it "reports multiple measures to librato" do
      expect(Librato::Metrics).to receive(:submit).with(
        gauges: [
          { name: 'pliny.foo', value: 1.5 },
          { name: 'pliny.bar', value: 2.04 }
        ]
      )

      backend.await._report_measures('pliny.foo' => 1.5, 'pliny.bar' => 2.04)
    end
  end
end
