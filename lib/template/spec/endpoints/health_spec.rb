require "spec_helper"

describe Endpoints::Health do
  include Rack::Test::Methods

  def app
    Endpoints::Health
  end

  describe 'GET /health' do
    it 'returns a 200' do
      get '/health'
      assert 200, last_response.status
    end
  end
end
