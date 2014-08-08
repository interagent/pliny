module Pliny::Helpers
  module Paginator
    class Paginator
      SORT_BY = /(?<sort_by>\w+)/
      VALUE = /[^\.\s;\/]+/
      FIRST = /(?<first>#{VALUE})/
      LAST = /(?<last>#{VALUE})/
      COUNT = /(?:\/\d+)/
      ARGS = /(?<args>.*)/
      RANGE = /\A#{SORT_BY}(?:\s+#{FIRST})?(\.{2}#{LAST})?#{COUNT}?(;\s*#{ARGS})?\z/

      attr_accessor :options
      attr_reader :sinatra, :count

      class << self
        def run(*args, &block)
          new(*args).run(&block)
        end
      end

      # Initializes an instance of Paginator
      #
      # @param [Sinatra::Base] the controller calling the paginator
      # @param [Integer] count the count of resources
      # @param [Hash] options for the paginator
      # @option options [Array<Symbol>] :accepted_ranges ([:id]) fields allowed to sort the listing
      # @option options [Symbol] :sort_by (:id) field to sort the listing
      # @option options [String] :first ID or name of the first element of the current page
      # @option options [String] :last ID or name of the last element of the current page
      # @option options [String] :next_first ID or name of the first element of the next page
      # @option options [String] :next_last ID or name of the last element of the next page
      # @option options [Hash] :args ({max: 200}) arguments for the HTTP Range header
      def initialize(sinatra, count, options = {})
        @sinatra = sinatra
        @count   = count
        @options =
          {
            accepted_ranges: [:id],
            sort_by: :id,
            first: nil,
            last: nil,
            next_first: nil,
            next_last: nil,
            args: { max: 200 }
          }
          .merge(options)
      end

      # executes the paginator and sets the HTTP headers if necessary
      #
      # @yieldparam paginator [Paginator]
      # @yieldreturn [Object]
      # @return [Object] the result of the block yielded
      def run
        options.merge!(request_options)

        result = yield(self) if block_given?

        halt unless valid_options?
        set_headers

        result
      end

      def request_options
        range = sinatra.request.env['Range']
        return {} if range.nil? || range.empty?

        match =
          RANGE.match(range)

        match ? parse_request_options(match) : halt
      end

      def parse_request_options(match)
        request_options = {}

        [:sort_by, :first, :last].each do |key|
          request_options[key] = match[key] if match[key]
        end

        if match[:args]
          args =
            match[:args]
              .split(/\s*,\s*/)
              .map do |value|
                k, v = value.split('=', 2)
                [k.to_sym, v]
              end

          request_options[:args] = Hash[args]
        end

        request_options
      end

      def valid_options?
        options[:sort_by] && options[:accepted_ranges].include?(options[:sort_by].to_sym)
      end

      def halt
        sinatra.halt(416)
      end

      def set_headers
        sinatra.headers 'Accept-Ranges' => options[:accepted_ranges].join(',')

        if will_paginate?
          sinatra.status 206

          cnt = build_range(options[:sort_by], options[:first], options[:last], options[:args], count)
          sinatra.headers 'Content-Range' => cnt

          if options[:next_first]
            nxt = build_range(options[:sort_by], options[:next_first], options[:next_last], options[:args])
            sinatra.headers 'Next-Range' => nxt
          end
        else
          sinatra.status 200
        end
      end

      def build_range(sort_by, first, last, args, count = nil)
        range = sort_by.to_s
        range << " #{[first, last].compact.join('..')}" if first
        range << "/#{count}" if count
        range << "; #{encode_args(args)}" if args
        range
      end

      def encode_args(args)
        args
          .map { |key, value| "#{key}=#{value}" }
          .join(',')
      end

      def will_paginate?
        count > options[:args][:max].to_i
      end

      def [](key)
        options[key.to_sym]
      end

      def []=(key, value)
        options[key.to_sym] = value
      end
    end
  end
end
