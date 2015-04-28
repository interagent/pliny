module Pliny
  module Measure
    def measure(name, options = {})
      start = Time.now
      return_value = yield if block_given?
      duration = Time.now - start
      log({"measure##{name}": (duration * 1000).round}.merge(options))
      return_value
    end

    def count(name, value = 1, options = {})
      log({"count##{name}": value}.merge(options))
    end
  end
end
