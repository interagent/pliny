desc "Rebuild schema.json"
task :schema do
  require "prmd"
  schemata = "./docs/schema.json"
  File.open(schemata, "w") do |f|
    f.puts Prmd.combine("./docs/schema/schemata", meta: "./docs/schema/meta.json")
  end
  puts "rebuilt #{schemata}"
end
