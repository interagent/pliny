module Endpoints
  class Health < Base
     namespace '/health' do
      get do
        encode({})
      end

      get '/db' do
        database?
        database_available?
        encode({})
      end

      private

      def database?
        raise Pliny::Errors::NotFound if DB.nil?
      end

      def database_available?
        raise Pliny::Errors::ServiceUnavailable unless DB.test_connection
      rescue Sequel::Error => e
        message = e.message.strip
        Pliny.log(db: true, health: true, at: 'exception', message: message)
        raise Pliny::Errors::ServiceUnavailable
      end
    end
  end
end
