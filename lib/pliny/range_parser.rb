module Pliny
  class RangeParser
    attr_reader :range_header
    attr_reader :start, :end, :parameters

    RANGE_FORMAT_ERROR = 'Invalid `Range` header. Please use format like `objects 0-99; sort=name, order=desc`.'.freeze

    def initialize(range_header)
      @range_header = range_header

      set_defaults
      return if range_header.nil?
      parse
    end

    private

    def parse
      parts = range_header.split(';')
      raise_range_format_error if parts.size > 2
    end

    def raise_range_format_error
      raise Pliny::Errors::BadRequest, RANGE_FORMAT_ERROR
    end

    def set_defaults
      @start = nil
      @end = nil
      @parameters = {}
    end
  end
end
