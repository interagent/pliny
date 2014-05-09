module Pliny
  module ConfigHelpers
    def optional(*attrs)
      attrs.each do |attr|
        instance_eval "def #{attr}; @#{attr} ||= ENV['#{attr.upcase}'] end", __FILE__, __LINE__
      end
    end

    def mandatory(*attrs)
      attrs.each do |attr|
        instance_eval "def #{attr}; @#{attr} ||= ENV['#{attr.upcase}'] || raise('missing=#{attr.upcase}') end", __FILE__, __LINE__
      end
    end

    def override(attrs)
      attrs.each do |attr, value|
        instance_eval "def #{attr}; @#{attr} ||= ENV['#{attr.upcase}'] || '#{value}'.to_s end", __FILE__, __LINE__
      end
    end
  end
end

# Supress the "use RbConfig instead" warning.
Object.send :remove_const, :Config
