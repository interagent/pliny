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

    def self.MakeError(status, id)
      Class.new(Pliny::Errors::Error) do
        @error_class_id = id
        @error_class_status = status
      end
    end

    BadRequest                   = MakeError(400, :bad_request)
    Unauthorized                 = MakeError(401, :unauthorized)
    PaymentRequired              = MakeError(402, :payment_required)
    Forbidden                    = MakeError(403, :forbidden)
    NotFound                     = MakeError(404, :not_found)
    MethodNotAllowed             = MakeError(405, :method_not_allowed)
    NotAcceptable                = MakeError(406, :not_acceptable)
    ProxyAuthenticationRequired  = MakeError(407, :proxy_authentication_required)
    RequestTimeout               = MakeError(408, :request_timeout)
    Conflict                     = MakeError(409, :conflict)
    Gone                         = MakeError(410, :gone)
    LengthRequired               = MakeError(411, :length_required)
    PreconditionFailed           = MakeError(412, :precondition_failed)
    RequestEntityTooLarge        = MakeError(413, :request_entity_too_large)
    RequestURITooLong            = MakeError(414, :request_uri_too_long)
    UnsupportedMediaType         = MakeError(415, :unsupported_media_type)
    RequestedRangeNotSatisfiable = MakeError(416, :requested_range_not_satisfiable)
    ExpectationFailed            = MakeError(417, :expectation_failed)
    UnprocessableEntity          = MakeError(422, :unprocessable_entity)
    TooManyRequests              = MakeError(429, :too_many_requests)
    InternalServerError          = MakeError(500, :internal_server_error)
    NotImplemented               = MakeError(501, :not_implemented)
    BadGateway                   = MakeError(502, :bad_gateway)
    ServiceUnavailable           = MakeError(503, :service_unavailable)
    GatewayTimeout               = MakeError(504, :gateway_timeout)
  end
end
