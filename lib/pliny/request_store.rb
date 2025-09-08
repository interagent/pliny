# frozen_string_literal: true

module Pliny
  module RequestStore
    def self.clear!
      Thread.current[:request_store] = {}
    end

    def self.seed(env)
      store[:request_id] =
        env["REQUEST_IDS"] ? env["REQUEST_IDS"].join(",") : nil

      # a global context that evolves over the lifetime of the request, and is
      # used to tag all log messages that it produces
      store[:log_context] = {
        request_id: store[:request_id],
      }
    end

    def self.store
      Thread.current[:request_store] ||= {}
    end
  end
end
