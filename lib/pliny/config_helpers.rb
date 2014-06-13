module Pliny
  module ConfigHelpers
    def optional(*attrs)
      attrs.each do |attr|
        instance_eval "def #{attr}; @#{attr} ||= ENV['#{attr.upcase}'] end", __FILE__, __LINE__
        ConfigHelpers.add_question_method(attr)
      end
    end

    def mandatory(*attrs)
      attrs.each do |attr|
        instance_eval "def #{attr}; @#{attr} ||= ENV['#{attr.upcase}'] || raise('missing=#{attr.upcase}') end", __FILE__, __LINE__
        ConfigHelpers.add_question_method(attr)
      end
    end

    def override(attrs)
      attrs.each do |attr, value|
        instance_eval "def #{attr}; @#{attr} ||= ENV['#{attr.upcase}'] || '#{value}'.to_s end", __FILE__, __LINE__
        ConfigHelpers.add_question_method(attr)
      end
    end

    def self.add_question_method(attr)
      define_method "#{attr}?" do
        return false if send(attr).nil?
        !!(send(attr) =~ /\Atrue|yes|on\z/i || send(attr).to_i > 0)
      end
    end
  end
end

# Supress the "use RbConfig instead" warning.
Object.send :remove_const, :Config
