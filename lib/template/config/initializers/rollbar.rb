Rollbar.configure do |config|
  config.enabled = ENV.has_key?('ROLLBAR_ACCESS_TOKEN')
  config.disable_rack_monkey_patch = true
  config.access_token = ENV["ROLLBAR_ACCESS_TOKEN"]
  config.environment = ENV['ROLLBAR_ENV']
  config.logger = Pliny::RollbarLogger.new
  config.use_sucker_punch
end

