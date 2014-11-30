RSpec.configure do |config|
  config.before(:context) do |spec|
    # weird ruby syntax, but test if the described_class inherits Sinatra::Base:
    if !@rack_app && spec.described_class < Sinatra::Base
      @rack_app = spec.described_class
    end
  end
end
