require "spec_helper"

describe Pliny::Errors do
  it "bundles classes to represent the different status codes" do
    error = Pliny::Errors::BadRequest.new
    assert_equal :bad_request, error.id
    assert_equal 400, error.status
    assert_equal "Bad request", error.user_message

    error = Pliny::Errors::InternalServerError.new
    assert_equal :internal_server_error, error.id
    assert_equal 500, error.status
    assert_equal "Internal server error", error.user_message
  end

  it "keeps the error id stored as the internal message" do
    error = Pliny::Errors::BadRequest.new
    assert_equal "bad_request", error.message
  end

  it "takes a custom id" do
    error = Pliny::Errors::BadRequest.new(:invalid_json)
    assert_equal :invalid_json, error.id
    assert_equal 400, error.status
  end

  it "takes optional metadata" do
    metadata = { foo: "bar" }
    error = Pliny::Errors::BadRequest.new(:invalid_json, metadata: metadata)
    assert_equal metadata, error.metadata
  end
end
