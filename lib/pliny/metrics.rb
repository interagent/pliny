module Pliny
  module Metrics
    def self.backend=(klass)
      @backend = klass
    end

    def self.backend
      @backend || Pliny::Metrics::Backends::Logger
    end

    def self.reset_backend
      remove_instance_variable(:@backend) if defined?(@backend)
    end

    def self.count(*names, value: 1)
      backend.count(*names, value: value)
    end

    def self.measure(*names, &block)
      backend.measure(*names, &block)
    end
  end
end
