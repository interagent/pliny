require "i18n"

module Pliny
  module Errors
    class Error < StandardError

      class << self
        attr_accessor :error_class_id, :error_class_status

        def render(error)
          headers = { "Content-Type" => "application/json; charset=utf-8" }
          data = { id: error.id, message: error.user_message }.merge(error.metadata)
          [error.status, headers, [MultiJson.encode(data)]]
        end
      end

      attr_accessor :id, :status, :metadata, :user_message

      def initialize(id=nil, metadata: {})
        @id = (id || self.class.error_class_id).to_sym
        @status = self.class.error_class_status
        @metadata = metadata
        @user_message = I18n.t("errors.#{@id}")
        super(@id.to_s)
      end
    end

    def self.make_error(status, id)
      Class.new(Pliny::Errors::Error) do
        @error_class_id = id
        @error_class_status = status
      end
    end

    BadRequest                   = make_error(400, :bad_request)
    Unauthorized                 = make_error(401, :unauthorized)
    PaymentRequired              = make_error(402, :payment_required)
    Forbidden                    = make_error(403, :forbidden)
    NotFound                     = make_error(404, :not_found)
    MethodNotAllowed             = make_error(405, :method_not_allowed)
    NotAcceptable                = make_error(406, :not_acceptable)
    ProxyAuthenticationRequired  = make_error(407, :proxy_authentication_required)
    RequestTimeout               = make_error(408, :request_timeout)
    Conflict                     = make_error(409, :conflict)
    Gone                         = make_error(410, :gone)
    LengthRequired               = make_error(411, :length_required)
    PreconditionFailed           = make_error(412, :precondition_failed)
    RequestEntityTooLarge        = make_error(413, :request_entity_too_large)
    RequestURITooLong            = make_error(414, :request_uri_too_long)
    UnsupportedMediaType         = make_error(415, :unsupported_media_type)
    RequestedRangeNotSatisfiable = make_error(416, :requested_range_not_satisfiable)
    ExpectationFailed            = make_error(417, :expectation_failed)
    UnprocessableEntity          = make_error(422, :unprocessable_entity)
    TooManyRequests              = make_error(429, :too_many_requests)
    InternalServerError          = make_error(500, :internal_server_error)
    NotImplemented               = make_error(501, :not_implemented)
    BadGateway                   = make_error(502, :bad_gateway)
    ServiceUnavailable           = make_error(503, :service_unavailable)
    GatewayTimeout               = make_error(504, :gateway_timeout)
  end
end
