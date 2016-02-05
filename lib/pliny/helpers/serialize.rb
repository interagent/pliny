require 'active_support/inflector'

module Pliny::Helpers
  module Serialize
    def self.included(base)
      base.send :extend, ClassMethods
    end

    # In every endpoint, use `serialize(model)` to serialize it. It will use
    # the serializer named like the endpoint (We usually use one serializer per
    # endpoint anyway)
    #
    # class Endpoints::User
    #   get '/users/:id'
    #     user = User.find(params[:id])
    #     # This will use Serializers::User
    #     encode serialize(user)
    #   end
    # end
    #
    def serialize(data, structure = :default)
      Serializers.const_get(self.class.serializer_name)
        .new(structure)
        .serialize(data)
    end

    module ClassMethods
      # Provide a way to specify endpoint serializer class.
      # For example in an actions endpoint,
      #
      # class Endpoints::User
      #   class Actions
      #     serializer 'User'
      #   end
      # end
      #
      # This will permits to user User serializer on all actions.
      def serializer(class_name)
        @serializer = class_name
      end

      def serializer_name
        @serializer ||= ActiveSupport::Inflector.demodulize(self.to_s)
      end
    end
  end
end
