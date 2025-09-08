# frozen_string_literal: true

module Pliny
  module Metrics
    module Backends
      class Logger
        def self.report_counts(counts)
          Pliny.log(add_prefix(:count, counts))
        end

        def self.report_measures(measures)
          Pliny.log(add_prefix(:measure, measures))
        end

        def self.add_prefix(type, metrics)
          metrics.map { |k, v| ["#{type}##{k}", v] }.to_h
        end

        private_class_method :add_prefix
      end
    end
  end
end
