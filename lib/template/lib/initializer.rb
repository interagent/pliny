module Initializer
  def self.run
    require_config
    load_locales
    require_lib
    require_initializers
    require_models
  end

  def self.require_config
    require_relative "../config/config"
  end

  def self.load_locales
    I18n.config.enforce_available_locales = true
    I18n.load_path += Dir[Config.root + "/config/locales/*.{rb,yml}"]
    I18n.backend.load_translations
  end

  def self.require_lib
    require! %w(
      lib/endpoints/base
      lib/endpoints/**/*
      lib/mediators/base
      lib/mediators/**/*
      lib/routes
      lib/serializers/base
      lib/serializers/**/*
    )
  end

  def self.require_models
    require! %w(
      lib/models/**/*
    )
  end

  def self.require_initializers
    Pliny::Utils.require_glob("#{Config.root}/config/initializers/*.rb")
  end

  def self.require!(globs)
    Array(globs).each do |f|
      Pliny::Utils.require_glob("#{Config.root}/#{f}.rb")
    end
  end
end

Initializer.run
