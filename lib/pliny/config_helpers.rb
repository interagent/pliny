# frozen_string_literal: true

module Pliny
  module CastingConfigHelpers
    def mandatory(name, method = nil)
      value = cast(ENV.fetch(name.to_s.upcase), method)
      create(name, value)
    end

    def optional(name, method = nil)
      value = cast(ENV[name.to_s.upcase], method)
      create(name, value)
    end

    def override(name, default, method = nil)
      value = cast(ENV.fetch(name.to_s.upcase, default), method)
      create(name, value)
    end

    def int
      ->(v) { v.to_i }
    end

    def float
      ->(v) { v.to_f }
    end

    def bool
      ->(v) { v.to_s == "true" }
    end

    def string
      nil
    end

    def symbol
      ->(v) { v.to_sym }
    end

    # optional :accronyms, array(string)
    # => ['a', 'b']
    # optional :numbers, array(int)
    # => [1, 2]
    # optional :notype, array
    # => ['a', 'b']
    def array(method = nil)
      ->(v) do
        v&.split(",")&.map { |a| cast(a, method) }
      end
    end

    def rack_env
      if env == "development" || env == "test"
        "development"
      else
        "deployment"
      end
    end

    # DEPRECATED: pliny_env is deprecated in favour of app_env.
    #             See more at https://github.com/interagent/pliny/issues/277
    #
    # This method is kept temporary in case it is used somewhere in the app.
    def pliny_env
      warn "Config.pliny_env is deprecated and will be removed, " \
           "use Config.app_env instead."
      env
    end

    private

    def cast(value, method)
      method ? method.call(value) : value
    end

    def create(name, value)
      instance_variable_set(:"@#{name}", value)
      instance_eval "def #{name}; @#{name} end", __FILE__, __LINE__
      if value.is_a?(TrueClass) || value.is_a?(FalseClass) || value.is_a?(NilClass)
        instance_eval "def #{name}?; !!@#{name} end", __FILE__, __LINE__
      end
    end

    # This method helps with transition from PLINY_ENV to APP_ENV.
    def env
      legacy_env || app_env
    end

    # PLINY_ENV is deprecated, but it might be still used by someone.
    def legacy_env
      if ENV.key?("PLINY_ENV")
        warn "PLINY_ENV is deprecated in favour of APP_ENV, " \
             "update .env file or application configuration."
        ENV["PLINY_ENV"]
      end
    end
  end

  # DEPRECATED: ConfigHelpers was a slightly more primitive version
  # of CastingConfigHelpers above that didn't contain any of the
  # latter's features around typing. It's been left here for
  # backwards compatibility in apps based on old templates that may
  # be using it.
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

# Supress the "use RbConfig instead" warning
if Object.const_defined?(:Config) && !Config.is_a?(Pliny::CastingConfigHelpers)
  Object.send(:remove_const, :Config)
end
