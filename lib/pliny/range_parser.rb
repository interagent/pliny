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
      bounds_str, parameters_str = parts
      parse_range_bounds(bounds_str)
      parse_range_parameters(parameters_str)
    end

    def parse_range_bounds(bounds_str)
      return if bounds_str.nil?
      unit, bounds = bounds_str.split(%r{\s+}, 2)
      raise_range_format_error unless unit.downcase == 'objects'
      if bounds =~ %r{(\d*)-(\d*)}
        @start = $1.to_i unless $1.empty?
        @end   = $2.to_i unless $2.empty?
      end
    end

    def parse_range_parameters(parameters_str)
      return if parameters_str.nil?
      @parameters = Hash[
        parameters_str.split(',')
        .map    { |option| option.split('=') }
        .select { |k, v| k && v }
        .map    { |k, v| [k.strip.to_sym, v.strip] }
      ]
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
