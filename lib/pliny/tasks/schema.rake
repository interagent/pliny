desc "Rebuild schema.json"
task :schema do
  require 'pliny/commands/generator/schema'
  Pliny::Commands::Generator::Schema.new(nil).rebuild
end
