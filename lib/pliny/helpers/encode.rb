module Pliny::Helpers
  module Encode
    def encode(object)
      content_type :json, charset: 'utf-8'
      MultiJson.encode(object, pretty: params[:pretty] == 'true' || Config.pretty_json)
    end
  end
end
