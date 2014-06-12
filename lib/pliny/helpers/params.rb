module Pliny::Helpers
  module Params
    def params
      @params ||= parse_params
    end

    private

    def parse_params
      if request.content_type == "application/json"
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
