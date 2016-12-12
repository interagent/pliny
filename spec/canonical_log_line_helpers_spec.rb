require "spec_helper"

describe Pliny::CanonicalLogLineHelpers do
  class TestCanonicalLogLine
    include CanonicalLogLineHelpers

    log_field :field_float, Float
    log_field :field_integer, Integer
    log_field :field_string, String
  end

  it "allows a field to be set" do
    line = TestCanonicalLogLine.new
    line.field_float = 3.14
    line.field_integer = 42
    line.field_string = "foo"
  end

  it "rejects values that are of the wrong type" do
  end
end
