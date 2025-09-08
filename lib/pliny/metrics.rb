# frozen_string_literal: true

module Pliny
  module Metrics
    extend self

    attr_accessor :backends

    @backends = [Backends::Logger]

    def count(*names, value: 1)
      counts = names.map { |n| ["#{Config.app_name}.#{n}", value] }.to_h

      backends.each do |backend|
        report_and_catch { backend.report_counts(counts) }
      end

      counts
    end

    def measure(*inputs, &block)
      if block
        elapsed, return_value = time_elapsed(&block)
      end

      opts = inputs.last.is_a?(Hash) ? inputs.pop : {}

      measurement =
        if opts.has_key?(:value)
          opts[:value]
        elsif block
          elapsed
        else
          0
        end

      measures = inputs.map { |n| ["#{Config.app_name}.#{n}", measurement] }.to_h

      backends.each do |backend|
        report_and_catch { backend.report_measures(measures) }
      end

      block ? return_value : measures
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
