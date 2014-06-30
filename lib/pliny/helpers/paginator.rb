module Pliny::Helpers
  module Paginator
    def paginator(count, options = {})
      Paginator.run(self, count, options)
    end

    class Paginator
      RANGE = /\A(?<sort_by>\S*)\s+(?<start>[0-9a-f-]+)(\.{2}(?<end>[0-9a-f-]+))?(;\s*(?<args>.*))?\z/

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
          start: res[:start],
          limit: res[:args][:max]
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
        range = sinatra.request.env['Range']
        return {} if range.nil? || range.empty?

        match =
          RANGE.match(range)

        if match
          request_options = {}

          [:sort_by, :start, :end].each do |key|
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
