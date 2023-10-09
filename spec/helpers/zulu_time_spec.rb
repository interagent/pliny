require "spec_helper"

describe Pliny::Helpers::ZuluTime do
  context "zulu_time" do
    class ZuluTimeTest
      extend Pliny::Helpers::ZuluTime
    end

    it "it formats Time instances" do
      formatted = ZuluTimeTest.zulu_time(Time.parse("2017-11-28T21:49:52.123+00:00"))
      assert_equal "2017-11-28T21:49:52Z", formatted
    end

    it "it formats DateTime instances" do
      formatted = ZuluTimeTest.zulu_time(DateTime.parse("2017-11-28T21:49:52.123+00:00"))
      assert_equal "2017-11-28T21:49:52Z", formatted
    end

    it "when called with nil" do
      assert_nil ZuluTimeTest.zulu_time(nil)
    end
  end
end
