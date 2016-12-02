module Pliny
  module Metrics
    def self.backend=(klass)
      @backend = klass
    end

    def self.backend
      @backend || Pliny::Metrics::Backends::Logger
    end

    def self.reset_backend
      remove_instance_variable(:@backend) if defined?(@backend)
    end

    def self.count(*names, value: 1)
      counts = Hash[names.map { |n| ["#{Config.app_name}.#{n}", value] }]
      backend.report_counts(counts)
      counts
    end

    def self.measure(*names, &block)
      elapsed, return_value = time_elapsed(&block)
      measures = Hash[names.map { |n| ["#{Config.app_name}.#{n}", elapsed] }]

      backend.report_measures(measures)

      return_value
    end

    def self.time_elapsed(&block)
      start = Time.now
      return_value = block.call
      [Time.now - start, return_value]
    end
  end
end
