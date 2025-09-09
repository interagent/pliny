# frozen_string_literal: true

module Pliny::Helpers
  module ZuluTime
    def zulu_time(time)
      time&.getutc&.strftime("%Y-%m-%dT%H:%M:%SZ")
    end
  end
end
