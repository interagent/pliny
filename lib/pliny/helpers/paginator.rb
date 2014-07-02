module Pliny::Helpers
  module Paginator
    def paginator(count, options = {}, &block)
      Paginator.run(self, count, options, &block)
    end

    def uuid_paginator(resource, options = {})
      paginator(resource.count, options) do |paginator|
        sort_by_conversion = { id: :uuid }
        resources = resource.order(sort_by_conversion[paginator[:sort_by].to_sym])

        if paginator.will_paginate?
          max = paginator[:args][:max].to_i
          resources = resources.limit(max)
          resources = resources.where { uuid >= Sequel.cast(paginator[:first], :uuid) } if paginator[:first]

          paginator.options.merge \
            first: resources.get(:uuid),
            last: resources.offset(max - 1).get(:uuid),
            next_first: resources.offset(max).get(:uuid),
            next_last: resources.offset(2 * max - 1).get(:uuid) || resources.select(:uuid).last.uuid
        end

        resources
      end
    end

    class Paginator
      SORT_BY = /(?<sort_by>\w+)/
      VALUE = /[^\.\s;\/]+/
      FIRST = /(?<first>#{VALUE})/
      LAST = /(?<last>#{VALUE})/
      COUNT = /(?:\/\d+)/
      ARGS = /(?<args>.*)/
      RANGE = /\A#{SORT_BY}(?:\s+#{FIRST})?(\.{2}#{LAST})?#{COUNT}?(;\s*#{ARGS})?\z/

      attr_reader :sinatra, :count
      attr_writer :options

      class << self
        def run(*args, &block)
          new(*args).run(&block)
        end
      end

      def initialize(sinatra, count, options = {})
        @sinatra = sinatra
        @count   = count
        @opts =
          {
            accepted_ranges: [:id],
            sort_by: :id,
            first: nil,
            args: { max: 200 }
          }
          .merge(options)
      end

      def run
        result = yield(self) if block_given?

        validate_options
        set_headers

        if block_given?
          result
        else
          {
            order_by: options[:sort_by],
            offset: options[:first],
            limit: options[:args][:max]
          }
        end
      end

      def options
        return @options if @options

        @options = @opts.merge(request_options)
        calculate_pages unless @options[:first].nil? || @options[:first].is_a?(String)

        @options
      end

      def calculate_pages
        options[:last] ||= options[:first] + options[:args][:max] - 1

        if options[:last] >= count - 1
          options[:last] = count - 1
          options[:next_first] = nil
          options[:next_last] = nil
        else
          options[:next_first] ||= options[:last] + 1
          options[:next_last] ||=
            [
              options[:next_first] + options[:args][:max] - 1,
              count - 1
            ]
            .min
        end
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

      def validate_options
        halt unless options[:sort_by] && options[:accepted_ranges].include?(options[:sort_by].to_sym)
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
