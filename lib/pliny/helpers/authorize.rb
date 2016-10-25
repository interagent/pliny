module Pliny::Helpers
  # Various helper methods for performing authorization.
  #
  # `authorize!` helper provided by this module makes call into defined
  # earlier authorizer.
  #
  # An authorizer can be set using `authorizer` method. An instance
  # of the authorizer must respond to `#authorized?` method
  # that accepts one parameter - a request object.
  #
  # Examples
  #
  #   module Endpoints
  #     class Foo < Base
  #       authorizer Authorizers::Digest
  #
  #       before { authorize! }
  #       ...
  #     end
  #   end
  module Authorize
    def self.included(base)
      base.send :extend, ClassMethods
    end

    # Makes call into the authorizer.
    #
    # Returns nothing.
    # Raises Pliny::Errors::Unauthorized if the request can't be authorized.
    def authorize!
      fail Pliny::Errors::Unauthorized unless authorized?
    end

    private

    def authorized?
      self.class.authorizer_instance.authorized?(request)
    end

    module ClassMethods
      # Set the instance of the authorizer.
      #
      # class_name - An authorizer Class. The instance of the class must
      #              respond to `authorized?` message.
      #
      # Returns nothing.
      def authorizer(class_name)
        @authorizer_instance = class_name.new
        nil
      end

      def authorizer_instance
        if @authorizer_instance.nil?
          fail RuntimeError, 'No authorizer has been specified for this ' \
                             'endpoint. Please specify one with ' \
                             '`authorizer AuthorizerClassName` in the endpoint.'
        end

        @authorizer_instance
      end
    end
  end
end
