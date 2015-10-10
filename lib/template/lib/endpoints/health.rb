module Endpoints
  class Health < Base
     namespace '/health' do
      get do
        encode {}
      end
    end
  end
end
