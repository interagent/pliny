# frozen_string_literal: true

unless ENV["TEST_LOGS"] == "true"
  module Pliny
    module Log
      def log(_data, &block)
        yield if block
      end
    end
  end
end
