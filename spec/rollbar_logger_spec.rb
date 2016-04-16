require "spec_helper"

describe Pliny::RollbarLogger do
  subject(:logger) { Pliny::RollbarLogger.new }

  let(:message) { 'hello world' }
  let(:log_context) { { rollbar: true, level: level, message: message } }

  before do
    mock(Pliny).log(log_context)
  end

  context '#debug' do
    let(:level) { 'debug' }

    it "proxies the debug log level" do
      logger.debug(message)
    end
  end

  context '#info' do
    let(:level) { 'info' }

    it "proxies the info log level" do
      logger.info(message)
    end
  end

  context '#warn' do
    let(:level) { 'warn' }

    it "proxies the warn log level" do
      logger.warn(message)
    end
  end

  context '#error' do
    let(:level) { 'error' }

    it "proxies the error log level" do
      logger.error(message)
    end
  end
end
