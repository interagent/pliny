require "spec_helper"

describe Pliny::Errors do
  describe Pliny::Errors::Error do
    it "takes a message" do
      e = Pliny::Errors::Error.new("Fail.")
      assert_equal "Fail.", e.message
    end
    it "takes an identifier" do
      e = Pliny::Errors::Error.new(nil, id: :fail)
      assert_equal :fail, e.id
    end

    it "takes metadata" do
      meta = { resource: "artists" }
      e = Pliny::Errors::Error.new(nil, metadata: meta)
      assert_equal meta, e.metadata
    end
  end

  describe Pliny::Errors::HTTPStatusError do
    it "includes an HTTP error that will take generic parameters" do
      e = Pliny::Errors::HTTPStatusError.new("error", id: :foo, status: 499)
      assert_equal :foo, e.id
      assert_equal 499, e.status
      assert_equal "error", e.message
    end

    it "includes pre-defined HTTP error templates" do
      e = Pliny::Errors::NotFound.new
      assert_equal "Not found.", e.message
      assert_equal :not_found, e.id
      assert_equal 404, e.status
    end
  end
end
