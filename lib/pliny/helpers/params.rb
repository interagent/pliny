module Pliny::Helpers
  module Params
    def body_params
      @body_params ||= parse_body_params
    end

    private

    def parse_body_params
      if request.media_type == "application/json"
        p = load_params(MultiJson.decode(request.body.read))
        request.body.rewind
        p
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
      if data.respond_to?(:to_hash)
        Sinatra::IndifferentHash[data.to_hash]
      elsif data.respond_to?(:to_ary)
        data.to_ary.map { |item| Sinatra::IndifferentHash[item] }
      else
        data
      end
    end
  end
end
