module Pliny::Helpers
  module Paginator

    # Sets the HTTP Range header for pagination if necessary
    #
    # @see uuid_paginator
    # @see integer_paginator
    # @see Pliny::Helpers::Paginator::Paginator
    def paginator(count, options = {}, &block)
      Paginator.run(self, count, options, &block)
    end

    # paginator for UUID columns
    #
    # @example call in the Endpoint
    #   articles = uuid_paginator(Article, args: { max: 10 })
    #
    # @example HTTP header returned
    #   Content-Range: id 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef/400; max=10
    #   Next-Range: id 76543210-89ab-cdef-0123-456789abcdef..76543210-89ab-cdef-0123-456789abcdef/400; max=10
    #
    # @param [Object] resource the resource to paginate
    # @param [Hash] options
    # @return [Object] modified resource (by order, limit and offset)
    # @see paginator
    def uuid_paginator(resource, options = {})
      paginator(resource.count, options) do |paginator|
        sort_by_conversion = { id: :uuid }
        max = paginator[:args][:max].to_i
        resources =
          resource
            .order(sort_by_conversion[paginator[:sort_by].to_sym])
            .limit(max)

        if paginator.will_paginate?
          resources = resources.where { uuid >= Sequel.cast(paginator[:first], :uuid) } if paginator[:first]

          paginator.options.merge! \
            first: resources.get(:uuid),
            last: resources.offset(max - 1).get(:uuid),
            next_first: resources.offset(max).get(:uuid),
            next_last: resources.offset(2 * max - 1).get(:uuid) || resources.select(:uuid).last.uuid
        end

        resources
      end
    end

    # paginator for integer columns
    #
    # @example call in the Endpoint
    #   paginator = integer_paginator(User.count)
    #   users = User.order(paginator[:order_by]).limit(paginator[:limit]).offset(paginator[:offset])
    #
    # @example HTTP header returned
    #   Content-Range: id 0..199/400; max=200
    #   Next-Range: id 200..399/400; max=200
    #
    # @param [Integer] count the count of resources
    # @param [Hash] options
    # @return [Hash] with :order_by and calculated :offset and :limit
    # @see paginator
    # @see Pliny::Helpers::Paginator::IntegerPaginator
    def integer_paginator(count, options = {})
      IntegerPaginator.run(self, count, options)
    end
  end
end
