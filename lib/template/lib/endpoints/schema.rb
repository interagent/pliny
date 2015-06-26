module Endpoints
  class Schema < Base
    get "/schema.json" do
      content_type("application/schema+json")
      response.headers["Cache-Control"] = "public, max-age=3600"
      filename = schema_filename
      unless File.exists?(filename)
        raise Pliny::Errors::NotFound.new("Schema")
      end
      File.read(filename)
    end

    private

    def schema_filename
      "#{Config.root}/schema/schema.json"
    end
  end
end
