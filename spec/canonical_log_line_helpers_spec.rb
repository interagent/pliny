require "spec_helper"

describe Pliny::CanonicalLogLineHelpers do
  class TestCanonicalLogLine
    include Pliny::CanonicalLogLineHelpers

    log_field :field_float, Float
    log_field :field_integer, Integer
    log_field :field_string, String
  end

  it "allows a field to be set" do
    line = TestCanonicalLogLine.new
    line.field_string = "foo"
  end

  it "allows nils to be set" do
    line = TestCanonicalLogLine.new
    line.field_string = nil
  end

  it "rejects values that are of the wrong type" do
    line = TestCanonicalLogLine.new
    e = assert_raises ArgumentError do
      line.field_string = 42
    end
    assert_equal "Expected field_string to be type String (was Fixnum)",
      e.message
  end

  it "produces a hash with #to_h" do
    line = TestCanonicalLogLine.new
    line.field_float = 3.14
    line.field_integer = 42
    line.field_string = "foo"
    assert_equal({ field_float: 3.14, field_integer: 42, field_string: "foo" },
      line.to_h)
  end
end
