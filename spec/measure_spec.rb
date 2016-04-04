require "spec_helper"

describe Pliny::Measure do
  before do
    @io = StringIO.new
    Pliny.stdout = @io
    stub(@io).print
  end

  describe '#measure' do
    it "logs in l2met structured format" do
      mock(@io).print "measure#request=0\n"
      Pliny.measure('request')
    end

    it "accepts an optional hash of options for logs" do
      mock(@io).print "measure#request=0 source=test\n"
      Pliny.measure('request', source: 'test')
    end
  end

  describe '#count' do
    it "logs in l2met structured format" do
      mock(@io).print "count#request=2\n"
      Pliny.count('request', 2)
    end

    it "has a default value" do
      mock(@io).print "count#request=1\n"
      Pliny.count('request')
    end

    it "accepts an optional hash of options for logs" do
      mock(@io).print "count#request=2 source=test\n"
      Pliny.count('request', 2, source: 'test')
    end
  end
end
