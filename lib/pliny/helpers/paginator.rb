module Pliny::Helpers
  module Paginator
    def paginator(count, options = {})
      Paginator.run(self, count, options)
    end

    class Paginator
      RANGE = /\A(?<sort_by>\S*)\s+(?<start>\d+)(\.{2}(?<end>\d+))?(;\s*(?<args>.*))?\z/

      attr_reader :sinatra, :count, :options
      attr_accessor :res

      class << self
        def run(*args)
          new(*args).run
        end
      end

      def initialize(sinatra, count, options = {})
        @sinatra = sinatra
        @count   = count
        @options = options
      end

      def run
        validate_options
        set_headers

        {
          sort_by: res[:sort_by],
          start: res[:start],
          limit: res[:max]
        }
      end

      def res
        return @res if @res

        @res =
          {
            accepted_ranges: [:id],
            sort_by: :id,
            start: 0,
            args: { max: 200 }
          }
          .merge(options)
          .merge(request_options)
      end

      def request_options
        return @request_options if @request_options

        match =
          RANGE.match(sinatra.request.env['Range'])

        @request_options = {}
        [:sort_by, :start, :end].each do |key|
          @request_options[key] = match[key] if match[key]
        end
        if match[:args]
          args =
            match[:args]
              .split(/\s*,\s*/)
              .map do |value|
                k, v = value.split('=', 2)
                [k.to_sym, v]
              end

          @request_options[:args] = Hash[args]
        end

        @request_options
      end

      def validate_options
        return if res[:accepted_ranges].include?(res[:sort_by].to_sym)

        sinatra.halt(416)
      end

      def set_headers
        sinatra.header 'Accept-Ranges', res[:accepted_ranges].join(',')

        if count > res[:args][:max]
          sinatra.status 206
          sinatra.headers \
            'Content-Range' => "#{res[:sort_by]} #{res[:start]}..#{res[:end]}/#{count}; #{args_encoded}",
            'Next-Range' => "#{res[:sort_by]} #{res[:end] + 1}..#{limit}; #{args_encoded}"
        else
          sinatra.status 200
        end
      end

      def args_encoded
        @args_encoded ||= res[:args].map { |key, value| "#{key}=#{value}" }.join(',')
      end

      def limit
        [
          res[:end] + res[:args][:max],
          count
        ]
        .min
      end
    end
  end
end
