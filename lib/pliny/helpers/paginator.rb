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

          paginator.options.merge! \
            first: resources.get(:uuid),
            last: resources.offset(max - 1).get(:uuid),
            next_first: resources.offset(max).get(:uuid),
            next_last: resources.offset(2 * max - 1).get(:uuid) || resources.select(:uuid).last.uuid
        end

        resources
      end
    end

    def integer_paginator(count, options = {})
      IntegerPaginator.run(self, count, options)
    end
  end
end
