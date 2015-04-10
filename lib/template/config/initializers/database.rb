database_setup_proc = lambda do |conn|
  conn.execute "set statement_timeout = '#{Config.database_timeout}s'"
end

Sequel.connect(Config.database_url,
  max_connections: Config.db_pool,
  after_connect: database_setup_proc)
