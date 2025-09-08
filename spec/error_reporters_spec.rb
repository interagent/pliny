# frozen_string_literal: true

require "spec_helper"

describe Pliny::ErrorReporters do
  subject(:reporter) { described_class }

  let(:reporter_double) { double("reporter").as_null_object }

  describe ".notify" do
    let(:exception) { RuntimeError.new }
    let(:context)   { { context: "foo" } }
    let(:rack_env)  { { rack_env: "bar" } }

    subject(:notify_reporter) do
      reporter.notify(exception, context: context, rack_env: rack_env)
    end

    before do
      Pliny::ErrorReporters.error_reporters << reporter_double

      allow(reporter_double).to receive(:notify)
    end

    after do
      Pliny::ErrorReporters.error_reporters = []
    end

    it "notifies rollbar" do
      notify_reporter

      expect(reporter_double).to have_received(:notify)
        .once
        .with(exception, context: context, rack_env: rack_env)
    end
  end
end
