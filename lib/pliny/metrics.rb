module Pliny
  module Metrics
    def self.count(*names, value: 1)
      counts = Hash[names.map { |n| [metric_prefix(:count, n), value] }]
      Pliny.log(counts)
    end

    def self.measure(*names, &block)
      elapsed, return_value = time_elapsed(&block)
      measures = Hash[names.map { |n| [metric_prefix(:measure, n), elapsed] }]
      Pliny.log(measures)

      return_value
    end

    private

    def self.metric_prefix(type, name)
      "#{type.to_s}##{Config.app_name}.#{name}"
    end

    def self.time_elapsed(&block)
      start = Time.now
      return_value = block.call
      [Time.now - start, return_value]
    end
  end
end

