require "spec_helper"

describe Pliny::Helpers::Authorize do
  context "with an authorizer" do
    class TokenAuthorizer
      def initialize
        @token = 'foo'
      end

      def authorized?(request)
        @token == request.params['access_token']
      end
    end

    def app
      Sinatra.new do
        helpers Pliny::Helpers::Authorize

        authorizer TokenAuthorizer

        get "/" do
          authorize!
        end
      end
    end

    it "passes requests with correct credentials" do
      get "/", access_token: 'foo'
      assert_equal 200, last_response.status
    end

    it "blocks requests with wrong or missing credentials" do
      assert_raises(Pliny::Errors::Unauthorized) do
        get "/"
      end
    end
  end

  context "without an authorizer" do
    def app
      Sinatra.new do
        helpers Pliny::Helpers::Authorize

        get "/" do
          authorize!
        end
      end
    end

    it "raises a runtime error" do
      assert_raises(RuntimeError) do
        get "/"
      end
    end
  end
end
