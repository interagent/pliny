desc "Rebuild schema.json"
task :schema do
  require 'pliny'
  Pliny::Commands::Generator.new.rebuild_schema
end
