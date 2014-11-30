class Mediators
  class Base
    def self.run(options={})
      new(options).call
    end
  end
end
