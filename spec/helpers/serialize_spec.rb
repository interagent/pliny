require "spec_helper"

describe Pliny::Helpers::Serialize do
  context "without a serializer" do
    def app
      Sinatra.new do
        helpers Pliny::Helpers::Serialize

        get "/" do
          MultiJson.encode(serialize([]))
        end
      end
    end

    it "raises a runtime error" do
      assert_raises(RuntimeError) do
        get "/"
      end
    end
  end

  context "with a serializer" do
    class Serializer
      def initialize(opts); end
      def serialize(data)
        data
      end
    end

    def app
      Sinatra.new do
        helpers Pliny::Helpers::Serialize

        serializer Serializer

        get "/" do
          MultiJson.encode(serialize([]))
        end
      end
    end

    it "encodes as json" do
      get "/"
      assert_equal 200, last_response.status
      assert_equal MultiJson.encode([]), last_response.body
    end

    it "measures time for serialiation" do
      get "/"
    end
  end
end
