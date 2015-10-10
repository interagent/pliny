require "spec_helper"

describe Endpoints::Health do
  include Rack::Test::Methods

  def app
    Endpoints::Health
  end

  describe 'GET /health' do
    it 'returns a 200' do
      get '/health'
      assert_equal(200, last_response.status)
      assert_equal('application/json;charset=utf-8', last_response.headers['Content-Type'])
      assert_equal(2, last_response.headers['Content-Length'].to_i)
      assert_equal({}, MultiJson.decode(last_response.body))
    end
  end
end
