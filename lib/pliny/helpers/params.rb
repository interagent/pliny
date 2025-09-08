# frozen_string_literal: true

module Pliny::Helpers
  module Params
    def body_params
      @body_params ||= parse_body_params
    end

    private

    def parse_body_params
      if request.media_type == "application/json"
        begin
          decoded = JSON.parse(request.body.read)
        rescue JSON::ParserError => e
          raise Pliny::Errors::BadRequest, e.message
        end
        request.body.rewind
        load_params(decoded)
      elsif request.form_data?
        load_params(request.POST)
      else
        {}
      end
    end

    def load_params(data)
      # Sinatra 1.x only supports the method. Sinatra 2.x only supports the class
      if defined?(Sinatra::IndifferentHash)
        indifferent_params_v2(data)
      else
        indifferent_params(data)
      end
    end

    def indifferent_params_v2(data)
      case data
      when Hash
        Sinatra::IndifferentHash[data]
      when Array
        data.map { |item| indifferent_params_v2(item) }
      else
        data
      end
    end
  end
end
