# frozen_string_literal: true

module Pliny::ErrorReporters
  extend self

  @error_reporters = []

  attr_accessor :error_reporters

  def notify(exception, context: {}, rack_env: {})
    Pliny.log_exception(exception)

    error_reporters.each do |reporter|
      reporter.new.notify(exception, context: context, rack_env: rack_env)
    rescue
      Pliny.log_exception($!)
    end
  end
end
