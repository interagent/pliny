require "pliny/config_helpers"

# Supress the "use RbConfig instead" warning.
if Object.const_defined?(:Config) && !Config.is_a?(Pliny::CastingConfigHelpers)
  Object.send(:remove_const, :Config)
end

module Config
  extend Pliny::CastingConfigHelpers

  def self.pretty_json
    true
  end
end
