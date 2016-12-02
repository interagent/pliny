begin
  require "librato/metrics"
rescue LoadError
  puts <<-MSG
! librato-metrics gem not found. Please add `gem "librato-metrics"` to
! your gemfile and run `bundle install` if you wish to use the Librato
! metrics backend

  MSG

  raise
end

module Pliny
  module Metrics
    module Backends
      module Librato
        def self.report_counts(counts)
          ::Librato::Metrics.submit(counters: expand_metrics(counts))
        end

        def self.report_measures(measures)
          ::Librato::Metrics.submit(gauges: expand_metrics(measures))
        end

        private

        def self.expand_metrics(metrics)
          metrics.map do |k, v|
            { name: k, value: v }
          end
        end
      end
    end
  end
end
