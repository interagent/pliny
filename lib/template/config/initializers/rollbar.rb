Rollbar.configure do |config|
  config.enabled = ENV.has_key?('ROLLBAR_ACCESS_TOKEN')
  config.environment = Config.pliny_env
  config.access_token = ENV["ROLLBAR_ACCESS_TOKEN"]
  config.use_sucker_punch
end

