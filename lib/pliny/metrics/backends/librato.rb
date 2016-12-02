begin
  require "librato/metrics"
  require "concurrent"
rescue LoadError => error
  puts <<-MSG
! #{error.message}
! Please add:
!   gem "librato-metrics"
!   gem "concurrent-ruby"
! to your gemfile and run `bundle install` if you wish to use the Librato
! metrics backend

  MSG

  raise
end

module Pliny
  module Metrics
    module Backends
      class Librato
        include Concurrent::Async

        def report_counts(counts)
          self.async._report_counts(counts)
        end

        def report_measures(measures)
          self.async._report_measures(measures)
        end

        def _report_counts(counts)
          ::Librato::Metrics.submit(counters: expand_metrics(counts))
        end

        def _report_measures(measures)
          ::Librato::Metrics.submit(gauges: expand_metrics(measures))
        end

        private

        def expand_metrics(metrics)
          metrics.map do |k, v|
            { name: k, value: v }
          end
        end
      end
    end
  end
end
