module Pliny
  module Metrics
    extend self

    attr_accessor :backends

    @backends = [Backends::Logger]

    def count(*names, value: 1)
      counts = Hash[names.map { |n| ["#{Config.app_name}.#{n}", value] }]

      backends.each do |backend|
        report_and_catch { backend.report_counts(counts) }
      end

      counts
    end

    def measure(*names, &block)
      elapsed, return_value = time_elapsed(&block)
      measures = Hash[names.map { |n| ["#{Config.app_name}.#{n}", elapsed] }]

      backends.each do |backend|
        report_and_catch { backend.report_measures(measures) }
      end

      return_value
    end

    private

    def time_elapsed(&block)
      start = Time.now
      return_value = block.call
      [Time.now - start, return_value]
    end

    def report_and_catch
      yield
    rescue => error
      Pliny.log_exception(error)
    end
  end
end
