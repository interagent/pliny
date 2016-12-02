require "spec_helper"
require_relative "../../../lib/pliny/metrics/backends/librato"

describe Pliny::Metrics::Backends::Librato do
  subject(:backend) { described_class }

  context "#report_counts" do
    it "reports a single count to librato" do
      expect(Librato::Metrics).to receive(:submit).with(
        counters: [
          { name: 'pliny.foo', value: 1 }
        ]
      )

      backend.report_counts('pliny.foo' => 1)
    end

    it "reports multiple counts to librato" do
      expect(Librato::Metrics).to receive(:submit).with(
        counters: [
          { name: 'pliny.foo', value: 1 },
          { name: 'pliny.bar', value: 2 }
        ]
      )

      backend.report_counts('pliny.foo' => 1, 'pliny.bar' => 2)
    end
  end

  context "#report_measures" do
    it "reports a single measure to librato" do
      expect(Librato::Metrics).to receive(:submit).with(
        gauges: [
          { name: 'pliny.foo', value: 1.002 }
        ]
      )

      backend.report_measures('pliny.foo' => 1.002)
    end

    it "reports multiple measures to librato" do
      expect(Librato::Metrics).to receive(:submit).with(
        gauges: [
          { name: 'pliny.foo', value: 1.5 },
          { name: 'pliny.bar', value: 2.04 }
        ]
      )

      backend.report_measures('pliny.foo' => 1.5, 'pliny.bar' => 2.04)
    end
  end
end
