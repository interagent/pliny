database_setup_proc = lambda do |conn|
  process_identifier = ENV["DYNO"] || File.basename($0)
  conn.execute "SET statement_timeout = '#{Config.database_timeout}s'"
  conn.execute "SET application_name = #{process_identifier}"
end

Sequel.connect(Config.database_url,
  max_connections: Config.db_pool,
  after_connect: database_setup_proc)
