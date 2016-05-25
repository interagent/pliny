require 'rollbar/exception_reporter'
require 'rollbar/request_data_extractor'

class Pliny::ErrorReporter
  def self.notify(exception, context: {}, rack_env: {})
    Pliny.log_exception(exception)

    REPORTERS.each do |reporter|
      begin
        reporter.new.notify(exception, context: context, rack_env: rack_env)
      rescue
        Pliny.log_exception($!)
      end
    end
  end

  class RollbarReporter
    include ::Rollbar::ExceptionReporter
    include ::Rollbar::RequestDataExtractor

    def notify(exception, context:, rack_env:)
      Rollbar.reset_notifier!
      scope = fetch_scope(context: context, rack_env: rack_env)
      Rollbar.scoped(scope) do
        report_exception_to_rollbar(rack_env, exception)
      end
    end

    private

    def fetch_scope(context:, rack_env:)
      {
        request: proc { extract_request_data_from_rack(rack_env) }
      }
    rescue Exception => e
      report_exception_to_rollbar(rack_env, e)
      raise
    end
  end

  REPORTERS = [RollbarReporter]
end
