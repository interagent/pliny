require "spec_helper"

describe Pliny::Middleware::Versioning do
  include Rack::Test::Methods
  before do
    @io = StringIO.new
    Pliny.stdout = @io
  end

  def app
    Rack::Builder.new do
      use Rack::Lint
      use Pliny::Middleware::Versioning, default: '2', app_name: 'pliny'
      run Sinatra.new {
        get "/" do
          MultiJson.encode env
        end
      }
    end
  end

  it "produces default version on application/json" do
    get '/', {}, {'HTTP_ACCEPT' => 'application/json'}
    json = MultiJson.decode(last_response.body)
    assert_equal 'application/json', json['HTTP_ACCEPT']
    assert_equal '2', json['HTTP_X_API_VERSION']
  end

  it "errors without a version specified on application/vnd.pliny+json" do
    get '/', {}, {'HTTP_ACCEPT' => 'application/vnd.pliny+json'}
    error = { id: :bad_version, message: <<-eos }
Please specify a version along with the MIME type. For example, `Accept: application/vnd.pliny+json; version=1`.
    eos

    assert_equal 400, last_response.status
    assert_equal MultiJson.encode(error), last_response.body
  end

  it "ignores a wrong app name" do
    get '/', {}, {'HTTP_ACCEPT' => 'application/vnd.chuck_norris+json'}
    json = MultiJson.decode(last_response.body)
    assert_equal 'application/vnd.chuck_norris+json', json['HTTP_ACCEPT']
    assert_equal '2', json['HTTP_X_API_VERSION']
  end

  it "produces a version on application/vnd.pliny+json; version=3" do
    get '/', {}, {'HTTP_ACCEPT' => 'application/vnd.pliny+json; version=3'}
    json = MultiJson.decode(last_response.body)
    assert_equal 'application/json', json['HTTP_ACCEPT']
    assert_equal '3', json['HTTP_X_API_VERSION']
  end

  it "handles a version with a variant" do
    get '/', {}, {'HTTP_ACCEPT' => 'application/vnd.pliny+json; version=3.variant_feature'}
    json = MultiJson.decode(last_response.body)
    assert_equal 'application/json', json['HTTP_ACCEPT']
    assert_equal '3', json['HTTP_X_API_VERSION']
    assert_equal 'variant_feature', json['HTTP_X_API_VARIANT']
  end

  # this behavior is pretty sketchy, but a pretty extreme edge case
  it "handles multiple MIME types" do
    get '/', {}, {'HTTP_ACCEPT' => 'application/vnd.pliny+json; version=3; q=0.5, text/xml'}
    json = MultiJson.decode(last_response.body)
    assert_equal 'text/xml, application/json; q=0.5', json['HTTP_ACCEPT']
    assert_equal '3', json['HTTP_X_API_VERSION']
  end

  it "handles multiple MIME types with variants" do
    get '/', {}, {'HTTP_ACCEPT' => 'application/vnd.pliny+json; version=3.variant; q=0.5, text/xml'}
    json = MultiJson.decode(last_response.body)
    assert_equal 'text/xml, application/json; q=0.5', json['HTTP_ACCEPT']
    assert_equal '3', json['HTTP_X_API_VERSION']
    assert_equal 'variant', json['HTTP_X_API_VARIANT']
  end

  it "produces the priority version on multiple types" do
    get '/', {}, {'HTTP_ACCEPT' => 'application/vnd.pliny+json; version=4; q=0.5, application/vnd.pliny+json; version=3'}
    json = MultiJson.decode(last_response.body)
    assert_equal 'application/json, application/json; q=0.5', json['HTTP_ACCEPT']
    assert_equal '3', json['HTTP_X_API_VERSION']
  end
end
