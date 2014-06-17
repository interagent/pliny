module Pliny::Helpers
  module Paginator
    def paginator(count, options = {})
      options =
        {
          accepted_ranges: [:id],
          order: :id,
          start: 0,
          max: 200
        }.merge(options)

      options[:end] = options[:start] + options[:max] - 1

      halt(400) unless options[:accepted_ranges].include?(options[:order].to_sym)

      headers 'Accept-Ranges' => options[:accepted_ranges].join(',')

      if count > options[:max]
        status 206
        headers \
          'Content-Range' => "#{options[:order]} #{options[:start]}..#{options[:end]}/#{count}; max=#{options[:max]}",
          'Next-Range' => "#{options[:order]} #{options[:end] + 1}..#{[options[:end] + options[:max], count].min}; max=#{options[:max]}"
      else
        status 200
      end

      {
        order: options[:order],
        start: options[:start],
        limit: options[:max]
      }
    end
  end
end
