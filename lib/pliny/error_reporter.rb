require_relative 'error_reporters/rollbar'

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

  REPORTERS = [Pliny::ErrorReporters::Rollbar]
end
