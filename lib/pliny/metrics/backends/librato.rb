begin
  require "librato/metrics"
rescue LoadError => error
  puts <<-MSG
! librato-metrics gem not found. Please add `gem "librato-metrics"` to
! your gemfile and run `bundle install` if you wish to use the Librato
! metrics backend

  MSG

  raise
end

module Pliny
  module Metrics
    module Backends
      module Librato
        def self.count(*keys, &block)

        end

        def self.measure(*keys, &block)

        end
      end
    end
  end
end
