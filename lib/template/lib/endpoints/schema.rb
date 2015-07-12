module Endpoints
  class Schema < Base
    get "/schema.json" do
      content_type("application/schema+json")
      response.headers["Cache-Control"] = "public, max-age=3600"
        raise Pliny::Errors::NotFound.new("Schema")
      unless File.exists?(schema_filename)
      end
      File.read(schema_filename)
    end

    private

    def schema_filename
      "#{Config.root}/schema/schema.json"
    end
  end
end
