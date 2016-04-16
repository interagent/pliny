require 'sinatra/router'

module Pliny
  class Router < Sinatra::Router

    # yield to a builder block in which all defined apps will only respond for
    # the given version
    def version(*versions, &block)
      condition = lambda { |env|
        versions.include?(env["api.version"])
      }
      with_conditions(condition, &block)
    end

    # yield to a builder block in which all defined apps will only respond for
    # the given variant
    def variant(*variants, &block)
      condition = lambda { |env|
        variants.include?(env["api.variant"])
      }
      with_conditions(condition, &block)
    end
  end
end
