module Pliny::Helpers
  module Params
    def body_params
      @body_params ||= parse_body_params
    end

    private

    def parse_body_params
      if request.media_type == "application/json"
        p = indifferent_params(MultiJson.decode(request.body.read))
        request.body.rewind
        p
      elsif request.form_data?
        indifferent_params(request.POST)
      else
        {}
      end
    end
  end
end
