# configure i18n to use locales from the template app
I18n.config.enforce_available_locales = true
I18n.load_path += Dir[File.dirname(__FILE__) + "/../../lib/template/config/locales/*.{rb,yml}"]
I18n.backend.load_translations
