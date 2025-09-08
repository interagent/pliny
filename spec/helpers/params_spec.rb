# frozen_string_literal: true

require "spec_helper"

describe Pliny::Helpers::Params do
  def app
    Sinatra.new do
      helpers Pliny::Helpers::Params
      post "/" do
        body_params.to_json
      end
    end
  end

  it "loads json params" do
    post "/", {hello: "world"}.to_json, {"CONTENT_TYPE" => "application/json"}
    assert_equal "{\"hello\":\"world\"}", last_response.body
  end

  it "loads json array of params" do
    post "/", [{hello: "world"}, {goodbye: "moon"}].to_json, {"CONTENT_TYPE" => "application/json"}
    assert_equal "[{\"hello\":\"world\"},{\"goodbye\":\"moon\"}]", last_response.body
  end

  it "loads json array of arrays of params" do
    post "/", [[{hello: "world"}], [{goodbye: "moon"}]].to_json, {"CONTENT_TYPE" => "application/json"}
    assert_equal "[[{\"hello\":\"world\"}],[{\"goodbye\":\"moon\"}]]", last_response.body
  end

  it "loads form data params" do
    post "/", {hello: "world"}
    assert_equal "{\"hello\":\"world\"}", last_response.body
  end

  it "loads from an unknown content type" do
    post "/", "<hello>world</hello>", {"CONTENT_TYPE" => "application/xml"}
    assert_equal "{}", last_response.body
  end

  it "should throw bad request when receiving invalid json via post" do
    err = assert_raises(Pliny::Errors::BadRequest) do
      post "/", "{\"foo\"}", {"CONTENT_TYPE" => "application/json"}
    end

    assert_match /expected ':' after object key at line 1 column 7/, err.message
  end
end
