# frozen_string_literal: true

database_setup_proc = lambda do |conn|
  # identify postgres connections coming from this process in pg_stat_activity
  process_identifier = ENV["DYNO"] || File.basename($PROGRAM_NAME).gsub(/\W+/, "_")
  conn.execute "SET statement_timeout = '#{Config.database_timeout}s'"
  conn.execute "SET application_name = '#{process_identifier}'"
end

DB = Sequel.connect(Config.database_url,
  max_connections: Config.db_pool,
  after_connect: database_setup_proc,)
