module Endpoints
  class Schema < Base
    get "/schema.json" do
      content_type "application/schema+json"
      headers["Cache-Control"] = "public, max-age=3600"
      unless File.exist?(schema_filename)
        message = "This application does not have a schema file."
        raise Pliny::Errors::NotFound, message
      end
      File.read(schema_filename)
    end

    private

    def schema_filename
      "#{Config.root}/schema/schema.json"
    end
  end
end
