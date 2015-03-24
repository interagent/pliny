Sequel.connect(Config.database_url,
               max_connections: Config.db_pool,
               after_connect: -> (c) { c.execute "set statement_timeout = '#{Config.database_timeout}s'"  })
