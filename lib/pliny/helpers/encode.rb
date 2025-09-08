# frozen_string_literal: true

module Pliny::Helpers
  module Encode
    def encode(object)
      content_type :json, charset: 'utf-8'
      if params[:pretty] == 'true' || Config.pretty_json
        JSON.pretty_generate(object)
      else
        JSON.generate(object)
      end
    end
  end
end
