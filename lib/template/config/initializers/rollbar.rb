require "pliny/error_reporters/rollbar"

Pliny::ErrorReporters.error_reporters << Pliny::ErrorReporters::Rollbar

Rollbar.configure do |config|
  config.enabled = ENV.key?("ROLLBAR_ACCESS_TOKEN")
  config.disable_rack_monkey_patch = true
  config.access_token = ENV["ROLLBAR_ACCESS_TOKEN"]
  config.environment = ENV["ROLLBAR_ENV"]
  config.logger = Pliny::RollbarLogger.new
  config.use_sucker_punch
end
