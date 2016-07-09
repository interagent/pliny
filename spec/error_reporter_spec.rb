
require "spec_helper"

describe Pliny::ErrorReporter do
  subject(:reporter) { described_class }

  describe ".notify" do
    let(:exception) { RuntimeError.new }
    let(:context)   { { context: "foo" } }
    let(:rack_env)  { { rack_env: "bar" } }

    subject(:notify_reporter) do
      reporter.notify(exception, context: context, rack_env: rack_env)
    end

    it "notifies rollbar" do
      expect_any_instance_of(Pliny::ErrorReporters::Rollbar).
        to receive(:notify).
        with(exception, context: context, rack_env: rack_env)

      notify_reporter
    end
  end
end
