# frozen_string_literal: true

require "sentry-ruby"

module Pliny
  module ErrorReporters
    class Sentry
      def notify(exception, context:, rack_env:)
        ::Sentry.with_scope do |scope|
          configure_scope(scope, context: context, rack_env: rack_env)
          ::Sentry.capture_exception(exception)
        end
      rescue Exception => e # rubocop:disable Lint/RescueException
        ::Sentry.capture_exception(e)
        raise
      end

      private

      def configure_scope(scope, context:, rack_env:)
        scope.set_context("custom", context)

        begin
          person_data = extract_person_data_from_controller(rack_env)
          if person_data && !person_data.empty?
            scope.set_user(
              id: person_data[:id],
              email: person_data[:email],
              username: person_data[:username],
            )
          end
        rescue => e
          ::Sentry.capture_exception(e)
        end
      end

      def extract_person_data_from_controller(env)
        if env.key?("sentry.person_data")
          env["sentry.person_data"] || {}
        else
          {}
        end
      end
    end
  end
end
