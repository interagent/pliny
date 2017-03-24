module Pliny::Helpers
  module Serialize
    def self.included(base)
      base.send :extend, ClassMethods
    end

    def serialize(data, structure = :default)
      serializer_class = self.class.serializer_class

      if serializer_class.nil?
        raise <<-eos.strip
No serializer has been specified for this endpoint. Please specify one with
`serializer Serializers::ModelName` in the endpoint.
        eos
      end

      env['pliny.serializer_arity'] = data.respond_to?(:size) ? data.size : 1

      start = Time.now
      serializer_class.new(structure).serialize(data).tap do
        env['pliny.serializer_timing'] = (Time.now - start).to_f
      end
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
