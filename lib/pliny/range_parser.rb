module Pliny
  class RangeParser
    attr_reader :range_header
    attr_reader :start, :end, :parameters

    def initialize(range_header)
      @range_header = range_header

      set_defaults
      return if range_header.nil?
      parse
    end

    private

    def parse

    end

    def set_defaults
      @start = nil
      @end = nil
      @parameters = {}
    end
  end
end
