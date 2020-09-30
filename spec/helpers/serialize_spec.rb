require "spec_helper"

describe Pliny::Helpers::Serialize do
  context "without a serializer" do
    def app
      Sinatra.new do
        register Pliny::Helpers::Serialize

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
        register Pliny::Helpers::Serialize

        serializer Serializer

        get "/" do
          MultiJson.encode(serialize([]))
        end

        get "/env" do
          MultiJson.encode(serialize(env))
        end
      end
    end

    it "encodes as json" do
      get "/"
      assert_equal 200, last_response.status
      assert_equal MultiJson.encode([]), last_response.body
    end

    it "emits information for canonical log lines" do
      get "/env"
      assert_equal 200, last_response.status
      body = MultiJson.decode(last_response.body)
      assert body["pliny.serializer_arity"] > 1
      assert body["pliny.serializer_timing"] > 0
    end
  end
end
