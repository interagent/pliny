module Pliny
  module Errors
    class Error < StandardError
      attr_accessor :id, :metadata

      def self.render(error)
        headers = { "Content-Type" => "application/json; charset=utf-8" }
        data = { id: error.id, message: error.message }.merge(error.metadata)
        [error.status, headers, [MultiJson.encode(data)]]
      end

      def initialize(message, id: nil, metadata: {})
        @id = id
        @metadata = metadata
        super(message)
      end
    end

    class HTTPStatusError < Error
      attr_accessor :status

      def initialize(message=nil, options={})
        meta = Pliny::Errors::META[self.class]
        message ||= "#{meta[1]}."
        options[:id] ||= meta[1].downcase.tr(' ', '_').to_sym
        @status = options.delete(:status) || meta[0]
        super(message, options)
      end
    end

    class BadRequest < HTTPStatusError; end                   # 400
    class Unauthorized < HTTPStatusError; end                 # 401
    class PaymentRequired < HTTPStatusError; end              # 402
    class Forbidden < HTTPStatusError; end                    # 403
    class NotFound < HTTPStatusError; end                     # 404
    class MethodNotAllowed < HTTPStatusError; end             # 405
    class NotAcceptable < HTTPStatusError; end                # 406
    class ProxyAuthenticationRequired < HTTPStatusError; end  # 407
    class RequestTimeout < HTTPStatusError; end               # 408
    class Conflict < HTTPStatusError; end                     # 409
    class Gone < HTTPStatusError; end                         # 410
    class LengthRequired < HTTPStatusError; end               # 411
    class PreconditionFailed < HTTPStatusError; end           # 412
    class RequestEntityTooLarge < HTTPStatusError; end        # 413
    class RequestURITooLong < HTTPStatusError; end            # 414
    class UnsupportedMediaType < HTTPStatusError; end         # 415
    class RequestedRangeNotSatisfiable < HTTPStatusError; end # 416
    class ExpectationFailed < HTTPStatusError; end            # 417
    class UnprocessableEntity < HTTPStatusError; end          # 422
    class TooManyRequests < HTTPStatusError; end              # 429
    class InternalServerError < HTTPStatusError; end          # 500
    class NotImplemented < HTTPStatusError; end               # 501
    class BadGateway < HTTPStatusError; end                   # 502
    class ServiceUnavailable < HTTPStatusError; end           # 503
    class GatewayTimeout < HTTPStatusError; end               # 504

    # Messages for nicer exceptions, from rfc2616
    META = {
      BadRequest                   => [400, 'Bad request'],
      Unauthorized                 => [401, 'Unauthorized'],
      PaymentRequired              => [402, 'Payment required'],
      Forbidden                    => [403, 'Forbidden'],
      NotFound                     => [404, 'Not found'],
      MethodNotAllowed             => [405, 'Method not allowed'],
      NotAcceptable                => [406, 'Not acceptable'],
      ProxyAuthenticationRequired  => [407, 'Proxy authentication required'],
      RequestTimeout               => [408, 'Request timeout'],
      Conflict                     => [409, 'Conflict'],
      Gone                         => [410, 'Gone'],
      LengthRequired               => [411, 'Length required'],
      PreconditionFailed           => [412, 'Precondition failed'],
      RequestEntityTooLarge        => [413, 'Request entity too large'],
      RequestURITooLong            => [414, 'Request-URI too long'],
      UnsupportedMediaType         => [415, 'Unsupported media type'],
      RequestedRangeNotSatisfiable => [416, 'Requested range not satisfiable'],
      ExpectationFailed            => [417, 'Expectation failed'],
      UnprocessableEntity          => [422, 'Unprocessable entity'],
      TooManyRequests              => [429, 'Too many requests'],
      InternalServerError          => [500, 'Internal server error'],
      NotImplemented               => [501, 'Not implemented'],
      BadGateway                   => [502, 'Bad gateway'],
      ServiceUnavailable           => [503, 'Service unavailable'],
      GatewayTimeout               => [504, 'Gateway timeout'],
    }.freeze
  end
end
