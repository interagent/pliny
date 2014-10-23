require "spec_helper"

describe Pliny::Errors do
  it "includes a general error that requires an identifier" do
    e = Pliny::Errors::Error.new("General error.", :general_error)
    assert_equal "General error.", e.message
    assert_equal :general_error, e.id
  end

  it "includes an HTTP error that will take generic parameters" do
    e = Pliny::Errors::HTTPStatusError.new(
      "Custom HTTP error.", :custom_http_error, 499)
    assert_equal "Custom HTTP error.", e.message
    assert_equal :custom_http_error, e.id
    assert_equal 499, e.status
  end

  it "includes pre-defined HTTP error templates" do
    e = Pliny::Errors::NotFound.new
    assert_equal "Not found.", e.message
    assert_equal :not_found, e.id
    assert_equal 404, e.status
  end
end
