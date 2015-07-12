module Endpoints
  class Schema < Base
    get "/schema.json" do
      content_type("application/schema+json")
      response.headers["Cache-Control"] = "public, max-age=3600"
      unless File.exists?(schema_filename)
        raise Pliny::Errors::NotFound.new("This application does not have a schema file.")
      end
      File.read(schema_filename)
    end

    private

    def schema_filename
      "#{Config.root}/schema/schema.json"
    end
  end
end
