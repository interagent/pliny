module Pliny::Helpers
  module Serialize
    def self.included(base)
      base.send :extend, ClassMethods
    end

    def serialize(data, structure = :default)
      self.class.serializer_class.new(structure).serialize(data)
    end

    module ClassMethods
      # Provide a way to specify endpoint serializer class.
      #
      # class Endpoints::User < Base
      #   serializer Serializers::User
      #
      #   get do
      #     encode serialize(User.all)
      #   end
      # end
      def serializer(serializer_class)
        @serializer_class = serializer_class
      end

      attr_reader :serializer_class
    end
  end
end
