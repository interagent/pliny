require 'pliny/commands/generator'
require 'pliny/commands/generator/endpoint'
require 'spec_helper'

describe Pliny::Commands::Generator::Endpoint do
  subject { Pliny::Commands::Generator::Endpoint.new(model_name, {}, StringIO.new) }
  let(:model_name) { 'resource_history' }

  describe '#url_path' do
    it 'builds a URL path' do
      assert_equal '/resource-histories', subject.url_path
    end
  end

  describe 'template' do
    before do
      # render the stub endpoint template to a string
      template = subject.render_template("endpoint.erb",
        plural_class_name: "Artists",
        url_path:          "/artists")

      # eval and assign it to rack_app so tests are pointing to it
      @rack_app = eval(template)
    end

    it "defines a stub GET" do
      get "/artists"
      assert_equal 200, last_response.status
      assert_equal [], MultiJson.decode(last_response.body)
    end

    it "defines a stub POST" do
      post "/artists"
      assert_equal 201, last_response.status
      assert_equal Hash.new, MultiJson.decode(last_response.body)
    end
  end
end
