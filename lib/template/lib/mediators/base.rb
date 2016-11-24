# frozen_string_literal: true
module Mediators
  class Base
    def self.run(options = {})
      new(options).call
    end
  end
end
