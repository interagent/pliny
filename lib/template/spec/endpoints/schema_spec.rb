require "spec_helper"

describe Endpoints::Schema do
  include Rack::Test::Methods

  let(:schema_filename) { "#{Config.root}/schema/schema.json" }

  subject(:get_schema) { get "/schema.json" }

  context "without a schema.json" do
    before do
      allow(File).to receive(:exists?).and_return(false)
    end

    it "raises a 404 on missing schema" do
      assert_raises(Pliny::Errors::NotFound) do
        get_schema
      end
    end
  end

  context "with a schema.json" do
    let(:contents) { "contents" }

    before do
      allow(File).to receive(:exists?).and_return(true)
      allow(File).to receive(:read).and_return(contents)
    end

    it "returns the schema is present" do
      get_schema
      assert_equal 200, last_response.status
      assert_equal "application/schema+json", last_response.headers["Content-Type"]
      assert_equal contents, last_response.body
    end
  end
end
