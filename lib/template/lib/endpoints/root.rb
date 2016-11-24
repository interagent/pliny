# frozen_string_literal: true
module Endpoints
  class Root < Base
    get '/' do
      'hello.'
    end
  end
end
