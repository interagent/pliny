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
      if respond_to?(:indifferent_params)
        indifferent_params(data)
      else
        Sinatra::IndifferentHash[data]
      end
    end
  end
end
