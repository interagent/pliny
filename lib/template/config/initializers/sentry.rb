# frozen_string_literal: true

require "pliny/error_reporters/sentry"

Pliny::ErrorReporters.error_reporters << Pliny::ErrorReporters::Sentry

Sentry.init do |config|
  config.dsn = ENV["SENTRY_DSN"]
  config.environment = ENV["SENTRY_ENV"] || ENV["RACK_ENV"]
  config.enabled_environments = %w[production staging]
  config.traces_sample_rate = 0.1
end

Pliny.use Sentry::Rack::CaptureExceptions
