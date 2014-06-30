module Pliny::Helpers
  module Paginator
    def paginator(count, options = {})
      Paginator.run(self, count, options)
    end

    class Paginator
      SORT_BY = /(?<sort_by>\S*)/
      UUID = /[0-9a-f-]+/i
      FIRST = /(?<first>#{UUID})/
      LAST = /(?<last>#{UUID})/
      COUNT = /(?:\/\d+)/
      ARGS = /(?<args>.*)/
      RANGE = /\A#{SORT_BY}\s+#{FIRST}(\.{2}#{LAST})?#{COUNT}?(;\s*#{ARGS})?\z/

      attr_reader :sinatra, :count, :options
      attr_accessor :res

      class << self
        def run(*args, &block)
          new(*args).run(&block)
        end
      end

      def initialize(sinatra, count, options = {})
        @sinatra = sinatra
        @count   = count
        @options = options
      end

      def run
        yield(self) if block_given?
        
        validate_options
        set_headers

        {
          sort_by: res[:sort_by],
          first: res[:first],
          limit: res[:args][:max]
        }
      end

      def res
        return @res if @res

        @res =
          {
            accepted_ranges: [:id],
            sort_by: :id,
            first: 0,
            args: { max: 200 }
          }
          .merge(options)
          .merge(request_options)
        unless @res[:first].kind_of?(String)
          @res[:last] ||= @res[:first] + @res[:args][:max]
          @res[:next_first] ||= @res[:last] + 1
          @res[:next_last] ||=
            [
              @res[:next_first] + @res[:args][:max],
              count - 1
            ]
            .min
        end

        @res
      end

      def request_options
        range = sinatra.request.env['Range']
        return {} if range.nil? || range.empty?

        match =
          RANGE.match(range)

        if match
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
        else
          halt
        end
      end

      def validate_options
        halt unless res[:accepted_ranges].include?(res[:sort_by].to_sym)
      end

      def halt
        sinatra.halt(416)
      end

      def set_headers
        sinatra.header 'Accept-Ranges', res[:accepted_ranges].join(',')

        if will_paginate?
          sinatra.status 206
          sinatra.headers \
            'Content-Range' => "#{res[:sort_by]} #{res[:first]}..#{res[:last]}/#{count}; #{args_encoded}",
            'Next-Range' => "#{res[:sort_by]} #{res[:next_first]}..#{res[:next_last]}; #{args_encoded}"
        else
          sinatra.status 200
        end
      end

      def args_encoded
        @args_encoded ||= res[:args].map { |key, value| "#{key}=#{value}" }.join(',')
      end

      def will_paginate?
        count > res[:args][:max].to_i
      end

      def [](key)
        res[key.to_sym]
      end

      def []=(key, value)
        res[key.to_sym] = value
      end
    end
  end
end
