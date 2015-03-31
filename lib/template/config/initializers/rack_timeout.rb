if Config.timeout > 0
  Rack::Timeout.timeout = Config.timeout
end
