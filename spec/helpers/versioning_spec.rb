require "spec_helper"

describe Pliny::Helpers::Versioning do
  def app
    Sinatra.new do
      helpers Pliny::Helpers::Versioning
      helpers Pliny::Helpers::Encode

      post "/" do
        encode({
          version: api_version,
          variant: api_variant
        })
      end
    end
  end

  before do
    stub(Config).pretty_json { false }
  end

  it "has no version and not variant" do
    post "/"
    assert_equal MultiJson.encode({version: nil, variant: nil}), last_response.body
  end

  it "has a version" do
    header "X_API_VERSION", "1"
    post "/"
    assert_equal MultiJson.encode({version: "1", variant: nil}), last_response.body
  end

  it "has a variant" do
    header "X_API_VERSION", "1"
    header "X_API_VARIANT", "my_variant"
    post "/"
    assert_equal MultiJson.encode({version: "1", variant: "my_variant"}), last_response.body
  end
end
