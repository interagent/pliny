RSpec.configure do |config|
  config.before :all do
    load('db/seeds.rb') if File.exist?('db/seeds.rb')
  end
end
