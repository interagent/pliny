module Pliny
  module Errors
    class Error < StandardError
      attr_accessor :id

      def self.render(error)
        headers = { "Content-Type" => "application/json; charset=utf-8" }
        data = { id: error.id, message: error.message, status: error.status }
        [error.status, headers, [MultiJson.encode(data)]]
      end

      def initialize(message, id)
        @id = id
        super(message)
      end
    end

    class HTTPStatusError < Error
      attr_accessor :status

      def initialize(message = nil, id = nil, status = nil)
        meta    = Pliny::Errors::META[self.class]
        message = message || meta[1] + "."
        id      = id || meta[1].downcase.gsub(/ /, '_').to_sym
        @status = status || meta[0]
        super(message, id)
      end
    end

    class Continue < HTTPStatusError; end                     # 100
    class SwitchingProtocols < HTTPStatusError; end           # 101
    class OK < HTTPStatusError; end                           # 200
    class Created < HTTPStatusError; end                      # 201
    class Accepted < HTTPStatusError; end                     # 202
    class NonAuthoritativeInformation < HTTPStatusError; end  # 203
    class NoContent < HTTPStatusError; end                    # 204
    class ResetContent < HTTPStatusError; end                 # 205
    class PartialContent < HTTPStatusError; end               # 206
    class MultipleChoices < HTTPStatusError; end              # 300
    class MovedPermanently < HTTPStatusError; end             # 301
    class Found < HTTPStatusError; end                        # 302
    class SeeOther < HTTPStatusError; end                     # 303
    class NotModified < HTTPStatusError; end                  # 304
    class UseProxy < HTTPStatusError; end                     # 305
    class TemporaryRedirect < HTTPStatusError; end            # 307
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
    class InternalServerError < HTTPStatusError; end          # 500
    class NotImplemented < HTTPStatusError; end               # 501
    class BadGateway < HTTPStatusError; end                   # 502
    class ServiceUnavailable < HTTPStatusError; end           # 503
    class GatewayTimeout < HTTPStatusError; end               # 504

    # Messages for nicer exceptions, from rfc2616
    META = {
      Continue                     => [100, 'Continue'],
      SwitchingProtocols           => [101, 'Switching protocols'],
      OK                           => [200, 'OK'],
      Created                      => [201, 'Created'],
      Accepted                     => [202, 'Accepted'],
      NonAuthoritativeInformation  => [203, 'Non-authoritative information'],
      NoContent                    => [204, 'No content'],
      ResetContent                 => [205, 'Reset content'],
      PartialContent               => [206, 'Partial content'],
      MultipleChoices              => [300, 'Multiple choices'],
      MovedPermanently             => [301, 'Moved permanently'],
      Found                        => [302, 'Found'],
      SeeOther                     => [303, 'See other'],
      NotModified                  => [304, 'Not modified'],
      UseProxy                     => [305, 'Use proxy'],
      TemporaryRedirect            => [307, 'Temporary redirect'],
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
      InternalServerError          => [500, 'Internal server error'],
      NotImplemented               => [501, 'Not implemented'],
      BadGateway                   => [502, 'Bad gateway'],
      ServiceUnavailable           => [503, 'Service unavailable'],
      GatewayTimeout               => [504, 'Gateway timeout'],
    }.freeze
  end
end
