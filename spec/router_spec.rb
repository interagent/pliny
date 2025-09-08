# frozen_string_literal: true

require "spec_helper"

describe Pliny::Router do
  describe "specifying a version" do
    def app
      Rack::Builder.new do
        use Rack::Lint
        use Pliny::Middleware::Versioning, default: "2", app_name: "pliny"

        use Pliny::Router do
          version "3" do
            mount Sinatra.new {
              get "/" do
                "API V3"
              end
            }
          end
        end

        run Sinatra.new {
          get "/" do
            "No API"
          end
        }
      end
    end

    it "should not run on any api" do
      get "/"
      assert_equal "No API", last_response.body
    end

    it "should run on API V3" do
      get "/", {}, {"HTTP_ACCEPT" => "application/vnd.pliny+json; version=3"}
      assert_equal "API V3", last_response.body
    end
  end
end
