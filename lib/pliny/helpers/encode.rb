module Pliny::Helpers
  module Encode
    def encode(object)
      MultiJson.encode(object, pretty: params[:pretty] == 'true' || Config.pretty_json)
    end
  end
end
