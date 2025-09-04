require "./config/config"

environment Config.rack_env
port Config.port
quiet
threads Config.puma_min_threads, Config.puma_max_threads
workers Config.puma_workers

before_worker_boot do
  # force Sequel's thread pool to be refreshed
  Sequel::DATABASES.each(&:disconnect)
end

preload_app!
Thread.abort_on_exception = true
