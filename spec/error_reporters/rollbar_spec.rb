require "spec_helper"
require "rollbar"
require "pliny/error_reporters/rollbar"

describe Pliny::ErrorReporters::Rollbar do
  subject(:reporter) { described_class.new }

  describe "#notify" do
    let(:exception) { StandardError.new("Something went wrong") }
    let(:context)   { {} }
    let(:rack_env)  { { "rack.input" => StringIO.new } }

    subject(:notify) do
      reporter.notify(exception, context: context, rack_env: rack_env)
    end

    before do
      allow(::Rollbar).to receive(:reset_notifier!)
      allow(::Rollbar).to receive(:scoped).and_yield
      allow(reporter).to receive(:report_exception_to_rollbar)
    end

    it "resets the rollbar notifier" do
      notify
      expect(::Rollbar).to have_received(:reset_notifier!).once
    end

    it "scopes the rollbar notification" do
      notify
      expect(::Rollbar).to have_received(:scoped).once.with(hash_including(
        request: instance_of(Proc)
      ))
    end

    it "delegates to #report_exception_to_rollbar" do
      notify
      expect(reporter).to have_received(:report_exception_to_rollbar)
        .once.with(rack_env, exception)
    end

    context "given an empty rack_env" do
      let(:rack_env) { {} }

      it "reports to Rollbar with an empty scope" do
        notify
        expect(Rollbar).to have_received(:scoped).once.with({})
      end

      it "delegates to #report_exception_to_rollbar" do
        notify
        expect(reporter).to have_received(:report_exception_to_rollbar)
          .once.with(rack_env, exception)
      end
    end
  end
end
