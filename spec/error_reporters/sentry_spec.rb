# frozen_string_literal: true

require "spec_helper"
require "sentry-ruby"
require "pliny/error_reporters/sentry"

describe Pliny::ErrorReporters::Sentry do
  subject(:reporter) { described_class.new }

  describe "#notify" do
    let(:exception) { StandardError.new("Something went wrong") }
    let(:context) { { step: :foo } }
    let(:rack_env) { { "rack.input" => StringIO.new } }

    subject(:notify) do
      reporter.notify(exception, context: context, rack_env: rack_env)
    end

    before do
      allow(::Sentry).to receive(:with_scope).and_yield(scope)
      allow(::Sentry).to receive(:capture_exception)
    end

    let(:scope) { instance_double("Sentry::Scope") }

    before do
      allow(scope).to receive(:set_context)
      allow(scope).to receive(:set_user)
    end

    it "creates a sentry scope" do
      notify
      expect(::Sentry).to have_received(:with_scope).once
    end

    it "sets custom context" do
      notify
      expect(scope).to have_received(:set_context).with("custom", { step: :foo })
    end

    it "captures the exception" do
      notify
      expect(::Sentry).to have_received(:capture_exception).with(exception)
    end

    context "given a rack_env with sentry.person_data" do
      let(:rack_env) { { "sentry.person_data" => { id: 123, email: "test@example.com", username: "testuser" }, "rack.input" => StringIO.new } }

      it "sets user context from sentry.person_data" do
        notify
        expect(scope).to have_received(:set_user).with(id: 123, email: "test@example.com", username: "testuser")
      end
    end

    context "given a rack_env with empty sentry.person_data" do
      let(:rack_env) { { "sentry.person_data" => {}, "rack.input" => StringIO.new } }

      it "does not set user context" do
        notify
        expect(scope).not_to have_received(:set_user)
      end
    end

    context "given an empty rack_env" do
      let(:rack_env) { {} }

      it "expects rack_env to be a hash" do
        assert_kind_of(Hash, rack_env)
      end

      it "sets only custom context" do
        notify
        expect(scope).to have_received(:set_context).once.with("custom", { step: :foo })
        expect(scope).not_to have_received(:set_user)
      end

      it "captures the exception" do
        notify
        expect(::Sentry).to have_received(:capture_exception).with(exception)
      end
    end
  end
end
