# frozen_string_literal: true

Pliny.default_context = {}
Pliny.default_context[:app] = Config.app_name if Config.app_name
Pliny.default_context[:deployment] = Config.deployment
