# frozen_string_literal: true

require "pliny/error_reporters/sentry"

Pliny::ErrorReporters.error_reporters << Pliny::ErrorReporters::Sentry

Sentry.init do |config|
  config.dsn = ENV["SENTRY_DSN"]
  config.environment = ENV["SENTRY_ENV"] || ENV["RACK_ENV"]
  config.enabled_environments = ENV["SENTRY_ENABLED_ENVIRONMENTS"]&.split(",") || %w[production staging]
  config.traces_sample_rate = ENV["SENTRY_TRACES_SAMPLE_RATE"]&.to_f || 0.1
end

Pliny.use Sentry::Rack::CaptureExceptions
