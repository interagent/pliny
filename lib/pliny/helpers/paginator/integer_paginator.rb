module Pliny::Helpers
  module Paginator
    class IntegerPaginator
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
        @opts    = options
      end

      def run
        {
          order_by: options[:sort_by],
          offset: options[:first],
          limit: options[:args][:max]
        }
      end

      def options
        @options ||= calculate_pages
      end

      def calculate_pages
        Paginator.run(self, count, @opts) do |paginator|
          max = paginator[:args][:max].to_i
          paginator[:last] =
            paginator[:first].to_i + max - 1

          if paginator[:last] >= count - 1
            paginator.options.merge! \
              last: count - 1,
              next_first: nil,
              next_last: nil
          else
            paginator[:next_first] =
              paginator[:last] + 1
            paginator[:next_last] =
              [
                paginator[:next_first] + max - 1,
                count - 1
              ]
              .min
          end

          paginator.options
        end
      end
    end
  end
end
