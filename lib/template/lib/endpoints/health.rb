module Endpoints
  class Health < Base
     namespace '/health' do
      get do
        200
      end
    end
  end
end
