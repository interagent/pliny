# Supress the "use RbConfig instead" warning.
Object.send(:remove_const, :Config) if Object.const_defined?(:Config)

module Config
  def self.pretty_json
    true
  end
end
